use super::debug_assert;
use super::common::*;
use super::d2s_intrinsics::*;
use super::d2s_full_table::*;
use super::pretty::*;
use core::ext::*;

pub static DOUBLE_MANTISSA_BITS: u32 = 52;
pub static DOUBLE_EXPONENT_BITS: u32 = 11;
pub static DOUBLE_BIAS: i32 = 1023;
pub static DOUBLE_POW5_INV_BITCOUNT: i32 = 125;
pub static DOUBLE_POW5_BITCOUNT: i32 = 125;

// A floating decimal representing m * 10^e.
pub struct FloatingDecimal64 {
    pub mantissa: u64,
    // Decimal exponent's range is -324 to 308
    // inclusive, and can fit in i16 if needed.
    pub exponent: i32,
}

pub fn d2d(ieee_mantissa: u64, ieee_exponent: u32): FloatingDecimal64 {
    let (e2, m2) = if ieee_exponent == 0 {
        // We subtract 2 so that the bounds computation has 2 additional bits.
        (1i32 - DOUBLE_BIAS - DOUBLE_MANTISSA_BITS as! i32 - 2, ieee_mantissa)
    } else {
        (
            ieee_exponent as! i32 - DOUBLE_BIAS - DOUBLE_MANTISSA_BITS as! i32 - 2,
            (1u64 << DOUBLE_MANTISSA_BITS) | ieee_mantissa,
        )
    };
    let even = (m2 & 1) == 0;
    let accept_bounds = even;

    // Step 2: Determine the interval of valid decimal representations.
    let mv = m2 * 4;
    // Implicit bool -> int conversion. True is 1, false is 0.
    let mm_shift = (ieee_mantissa != 0 || ieee_exponent <= 1) as u32;
    // We would compute mp and mm like this:
    // uint64_t mp = 4 * m2 + 2;
    // uint64_t mm = mv - 1 - mm_shift;

    // Step 3: Convert to a decimal power base using 128-bit arithmetic.
    mut vr: u64;
    mut vp: u64;
    mut vm: u64;
    mut e10: i32;
    mut vm_is_trailing_zeros = false;
    mut vr_is_trailing_zeros = false;
    if e2 >= 0 {
        // I tried special-casing q == 0, but there was no effect on performance.
        // This expression is slightly faster than max(0, log10_pow2(e2) - 1).
        let q = log10_pow2(e2) - (e2 > 3) as u32;
        e10 = q as! i32;
        let k = DOUBLE_POW5_INV_BITCOUNT + pow5bits(q as! i32) - 1;
        let i = -e2 + q as! i32 + k;
        vr = unsafe {
            mul_shift_all_64(
                m2,
                {
                    debug_assert(q < DOUBLE_POW5_INV_TABLE_SIZE as! u32);
                    &DOUBLE_POW5_INV_SPLIT[q as! int]
                },
                i as u32,
                &mut vp,
                &mut vm,
                mm_shift,
            )
        };
        if q <= 21 {
            // This should use q <= 22, but I think 21 is also safe. Smaller values
            // may still be safe, but it's more difficult to reason about them.
            // Only one of mp, mv, and mm can be a multiple of 5, if any.
            let mv_mod5 = (mv as! u32).wrapping_sub(5u32.wrapping_mul((mv / 5) as! u32));
            if mv_mod5 == 0 {
                vr_is_trailing_zeros = multiple_of_power_of_5(mv, q);
            } else if accept_bounds {
                // Same as min(e2 + (~mm & 1), pow5_factor(mm)) >= q
                // <=> e2 + (~mm & 1) >= q && pow5_factor(mm) >= q
                // <=> true && pow5_factor(mm) >= q, since e2 >= q.
                vm_is_trailing_zeros = multiple_of_power_of_5(mv - 1 - mm_shift as u64, q);
            } else {
                // Same as min(e2 + 1, pow5_factor(mp)) >= q.
                vp -= multiple_of_power_of_5(mv + 2, q) as u64;
            }
        }
    } else {
        // This expression is slightly faster than max(0, log10_pow5(-e2) - 1).
        let q = log10_pow5(-e2) - (-e2 > 1) as u32;
        e10 = q as! i32 + e2;
        let i = -e2 - q as! i32;
        let k = pow5bits(i) - DOUBLE_POW5_BITCOUNT;
        let j = q as! i32 - k;
        vr = unsafe {
            mul_shift_all_64(
                m2,
                {
                    debug_assert(i < DOUBLE_POW5_TABLE_SIZE as! i32);
                    &DOUBLE_POW5_SPLIT[i as int]
                },
                j as u32,
                &mut vp,
                &mut vm,
                mm_shift,
            )
        };
        if q <= 1 {
            // {vr,vp,vm} is trailing zeros if {mv,mp,mm} has at least q trailing 0 bits.
            // mv = 4 * m2, so it always has at least two trailing 0 bits.
            vr_is_trailing_zeros = true;
            if accept_bounds {
                // mm = mv - 1 - mm_shift, so it has 1 trailing 0 bit iff mm_shift == 1.
                vm_is_trailing_zeros = mm_shift == 1;
            } else {
                // mp = mv + 2, so it always has at least one trailing 0 bit.
                vp--;
            }
        } else if q < 63 {
            // TODO(ulfjack): Use a tighter bound here.
            // We want to know if the full product has at least q trailing zeros.
            // We need to compute min(p2(mv), p5(mv) - e2) >= q
            // <=> p2(mv) >= q && p5(mv) - e2 >= q
            // <=> p2(mv) >= q (because -e2 >= q)
            vr_is_trailing_zeros = multiple_of_power_of_2(mv, q);
        }
    }

    // Step 4: Find the shortest decimal representation in the interval of valid representations.
    mut removed = 0i32;
    mut last_removed_digit = 0u8;
    // On average, we remove ~2 digits.
    let output = if vm_is_trailing_zeros || vr_is_trailing_zeros {
        // General case, which happens rarely (~0.7%).
        loop {
            let vp_div10 = vp / 10;
            let vm_div10 = vm / 10;
            if vp_div10 <= vm_div10 {
                break;
            }
            let vm_mod10 = (vm as! u32).wrapping_sub(10u32.wrapping_mul(vm_div10 as! u32));
            let vr_div10 = vr / 10;
            let vr_mod10 = (vr as! u32).wrapping_sub(10u32.wrapping_mul(vr_div10 as! u32));
            vm_is_trailing_zeros &= vm_mod10 == 0;
            vr_is_trailing_zeros &= last_removed_digit == 0;
            last_removed_digit = vr_mod10 as! u8;
            vr = vr_div10;
            vp = vp_div10;
            vm = vm_div10;
            removed++;
        }
        if vm_is_trailing_zeros {
            loop {
                let vm_div10 = vm / 10;
                let vm_mod10 = (vm as! u32).wrapping_sub(10u32.wrapping_mul(vm_div10 as! u32));
                if vm_mod10 != 0 {
                    break;
                }
                let vp_div10 = vp / 10;
                let vr_div10 = vr / 10;
                let vr_mod10 = (vr as! u32).wrapping_sub(10u32.wrapping_mul(vr_div10 as! u32));
                vr_is_trailing_zeros &= last_removed_digit == 0;
                last_removed_digit = vr_mod10 as! u8;
                vr = vr_div10;
                vp = vp_div10;
                vm = vm_div10;
                removed++;
            }
        }
        if vr_is_trailing_zeros && last_removed_digit == 5 && vr % 2 == 0 {
            // Round even if the exact number is .....50..0.
            last_removed_digit = 4;
        }
        // We need to take vr + 1 if vr is outside bounds or we need to round up.
        vr + ((vr == vm && (!accept_bounds || !vm_is_trailing_zeros)) || last_removed_digit >= 5)
            as u64
    } else {
        // Specialized for the common case (~99.3%). Percentages below are relative to this.
        mut round_up = false;
        let vp_div100 = vp / 100;
        let vm_div100 = vm / 100;
        // Optimization: remove two digits at a time (~86.2%).
        if vp_div100 > vm_div100 {
            let vr_div100 = vr / 100;
            let vr_mod100 = (vr as! u32).wrapping_sub(100u32.wrapping_mul(vr_div100 as! u32));
            round_up = vr_mod100 >= 50;
            vr = vr_div100;
            vp = vp_div100;
            vm = vm_div100;
            removed += 2;
        }
        // Loop iterations below (approximately), without optimization above:
        // 0: 0.03%, 1: 13.8%, 2: 70.6%, 3: 14.0%, 4: 1.40%, 5: 0.14%, 6+: 0.02%
        // Loop iterations below (approximately), with optimization above:
        // 0: 70.6%, 1: 27.8%, 2: 1.40%, 3: 0.14%, 4+: 0.02%
        loop {
            let vp_div10 = vp / 10;
            let vm_div10 = vm / 10;
            if vp_div10 <= vm_div10 {
                break;
            }
            let vr_div10 = vr / 10;
            let vr_mod10 = (vr as! u32).wrapping_sub(10u32.wrapping_mul(vr_div10 as! u32));
            round_up = vr_mod10 >= 5;
            vr = vr_div10;
            vp = vp_div10;
            vm = vm_div10;
            removed++;
        }
        // We need to take vr + 1 if vr is outside bounds or we need to round up.
        vr + (vr == vm || round_up) as u64
    };
    FloatingDecimal64(
        exponent: e10 + removed,
        mantissa: output,
    )
}
