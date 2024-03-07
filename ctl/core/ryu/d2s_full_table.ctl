pub static DOUBLE_POW5_INV_TABLE_SIZE: uint = 342;
pub static DOUBLE_POW5_TABLE_SIZE: uint = 326;

pub static DOUBLE_POW5_INV_SPLIT: [(u64, u64); 342] = [
    (1, 2305843009213693952),
    (11068046444225730970, 1844674407370955161),
    (5165088340638674453, 1475739525896764129),
    (7821419487252849886, 1180591620717411303),
    (8824922364862649494, 1888946593147858085),
    (7059937891890119595, 1511157274518286468),
    (13026647942995916322, 1208925819614629174),
    (9774590264567735146, 1934281311383406679),
    (11509021026396098440, 1547425049106725343),
    (16585914450600699399, 1237940039285380274),
    (15469416676735388068, 1980704062856608439),
    (16064882156130220778, 1584563250285286751),
    (9162556910162266299, 1267650600228229401),
    (7281393426775805432, 2028240960365167042),
    (16893161185646375315, 1622592768292133633),
    (2446482504291369283, 1298074214633706907),
    (7603720821608101175, 2076918743413931051),
    (2393627842544570617, 1661534994731144841),
    (16672297533003297786, 1329227995784915872),
    (11918280793837635165, 2126764793255865396),
    (5845275820328197809, 1701411834604692317),
    (15744267100488289217, 1361129467683753853),
    (3054734472329800808, 2177807148294006166),
    (17201182836831481939, 1742245718635204932),
    (6382248639981364905, 1393796574908163946),
    (2832900194486363201, 2230074519853062314),
    (5955668970331000884, 1784059615882449851),
    (1075186361522890384, 1427247692705959881),
    (12788344622662355584, 2283596308329535809),
    (13920024512871794791, 1826877046663628647),
    (3757321980813615186, 1461501637330902918),
    (10384555214134712795, 1169201309864722334),
    (5547241898389809503, 1870722095783555735),
    (4437793518711847602, 1496577676626844588),
    (10928932444453298728, 1197262141301475670),
    (17486291911125277965, 1915619426082361072),
    (6610335899416401726, 1532495540865888858),
    (12666966349016942027, 1225996432692711086),
    (12888448528943286597, 1961594292308337738),
    (17689456452638449924, 1569275433846670190),
    (14151565162110759939, 1255420347077336152),
    (7885109000409574610, 2008672555323737844),
    (9997436015069570011, 1606938044258990275),
    (7997948812055656009, 1285550435407192220),
    (12796718099289049614, 2056880696651507552),
    (2858676849947419045, 1645504557321206042),
    (13354987924183666206, 1316403645856964833),
    (17678631863951955605, 2106245833371143733),
    (3074859046935833515, 1684996666696914987),
    (13527933681774397782, 1347997333357531989),
    (10576647446613305481, 2156795733372051183),
    (15840015586774465031, 1725436586697640946),
    (8982663654677661702, 1380349269358112757),
    (18061610662226169046, 2208558830972980411),
    (10759939715039024913, 1766847064778384329),
    (12297300586773130254, 1413477651822707463),
    (15986332124095098083, 2261564242916331941),
    (9099716884534168143, 1809251394333065553),
    (14658471137111155161, 1447401115466452442),
    (4348079280205103483, 1157920892373161954),
    (14335624477811986218, 1852673427797059126),
    (7779150767507678651, 1482138742237647301),
    (2533971799264232598, 1185710993790117841),
    (15122401323048503126, 1897137590064188545),
    (12097921058438802501, 1517710072051350836),
    (5988988032009131678, 1214168057641080669),
    (16961078480698431330, 1942668892225729070),
    (13568862784558745064, 1554135113780583256),
    (7165741412905085728, 1243308091024466605),
    (11465186260648137165, 1989292945639146568),
    (16550846638002330379, 1591434356511317254),
    (16930026125143774626, 1273147485209053803),
    (4951948911778577463, 2037035976334486086),
    (272210314680951647, 1629628781067588869),
    (3907117066486671641, 1303703024854071095),
    (6251387306378674625, 2085924839766513752),
    (16069156289328670670, 1668739871813211001),
    (9165976216721026213, 1334991897450568801),
    (7286864317269821294, 2135987035920910082),
    (16897537898041588005, 1708789628736728065),
    (13518030318433270404, 1367031702989382452),
    (6871453250525591353, 2187250724783011924),
    (9186511415162383406, 1749800579826409539),
    (11038557946871817048, 1399840463861127631),
    (10282995085511086630, 2239744742177804210),
    (8226396068408869304, 1791795793742243368),
    (13959814484210916090, 1433436634993794694),
    (11267656730511734774, 2293498615990071511),
    (5324776569667477496, 1834798892792057209),
    (7949170070475892320, 1467839114233645767),
    (17427382500606444826, 1174271291386916613),
    (5747719112518849781, 1878834066219066582),
    (15666221734240810795, 1503067252975253265),
    (12532977387392648636, 1202453802380202612),
    (5295368560860596524, 1923926083808324180),
    (4236294848688477220, 1539140867046659344),
    (7078384693692692099, 1231312693637327475),
    (11325415509908307358, 1970100309819723960),
    (9060332407926645887, 1576080247855779168),
    (14626963555825137356, 1260864198284623334),
    (12335095245094488799, 2017382717255397335),
    (9868076196075591040, 1613906173804317868),
    (15273158586344293478, 1291124939043454294),
    (13369007293925138595, 2065799902469526871),
    (7005857020398200553, 1652639921975621497),
    (16672732060544291412, 1322111937580497197),
    (11918976037903224966, 2115379100128795516),
    (5845832015580669650, 1692303280103036413),
    (12055363241948356366, 1353842624082429130),
    (841837113407818570, 2166148198531886609),
    (4362818505468165179, 1732918558825509287),
    (14558301248600263113, 1386334847060407429),
    (12225235553534690011, 2218135755296651887),
    (2401490813343931363, 1774508604237321510),
    (1921192650675145090, 1419606883389857208),
    (17831303500047873437, 2271371013423771532),
    (6886345170554478103, 1817096810739017226),
    (1819727321701672159, 1453677448591213781),
    (16213177116328979020, 1162941958872971024),
    (14873036941900635463, 1860707134196753639),
    (15587778368262418694, 1488565707357402911),
    (8780873879868024632, 1190852565885922329),
    (2981351763563108441, 1905364105417475727),
    (13453127855076217722, 1524291284333980581),
    (7073153469319063855, 1219433027467184465),
    (11317045550910502167, 1951092843947495144),
    (12742985255470312057, 1560874275157996115),
    (10194388204376249646, 1248699420126396892),
    (1553625868034358140, 1997919072202235028),
    (8621598323911307159, 1598335257761788022),
    (17965325103354776697, 1278668206209430417),
    (13987124906400001422, 2045869129935088668),
    (121653480894270168, 1636695303948070935),
    (97322784715416134, 1309356243158456748),
    (14913111714512307107, 2094969989053530796),
    (8241140556867935363, 1675975991242824637),
    (17660958889720079260, 1340780792994259709),
    (17189487779326395846, 2145249268790815535),
    (13751590223461116677, 1716199415032652428),
    (18379969808252713988, 1372959532026121942),
    (14650556434236701088, 2196735251241795108),
    (652398703163629901, 1757388200993436087),
    (11589965406756634890, 1405910560794748869),
    (7475898206584884855, 2249456897271598191),
    (2291369750525997561, 1799565517817278553),
    (9211793429904618695, 1439652414253822842),
    (18428218302589300235, 2303443862806116547),
    (7363877012587619542, 1842755090244893238),
    (13269799239553916280, 1474204072195914590),
    (10615839391643133024, 1179363257756731672),
    (2227947767661371545, 1886981212410770676),
    (16539753473096738529, 1509584969928616540),
    (13231802778477390823, 1207667975942893232),
    (6413489186596184024, 1932268761508629172),
    (16198837793502678189, 1545815009206903337),
    (5580372605318321905, 1236652007365522670),
    (8928596168509315048, 1978643211784836272),
    (18210923379033183008, 1582914569427869017),
    (7190041073742725760, 1266331655542295214),
    (436019273762630246, 2026130648867672343),
    (7727513048493924843, 1620904519094137874),
    (9871359253537050198, 1296723615275310299),
    (4726128361433549347, 2074757784440496479),
    (7470251503888749801, 1659806227552397183),
    (13354898832594820487, 1327844982041917746),
    (13989140502667892133, 2124551971267068394),
    (14880661216876224029, 1699641577013654715),
    (11904528973500979224, 1359713261610923772),
    (4289851098633925465, 2175541218577478036),
    (18189276137874781665, 1740432974861982428),
    (3483374466074094362, 1392346379889585943),
    (1884050330976640656, 2227754207823337509),
    (5196589079523222848, 1782203366258670007),
    (15225317707844309248, 1425762693006936005),
    (5913764258841343181, 2281220308811097609),
    (8420360221814984868, 1824976247048878087),
    (17804334621677718864, 1459980997639102469),
    (17932816512084085415, 1167984798111281975),
    (10245762345624985047, 1868775676978051161),
    (4507261061758077715, 1495020541582440929),
    (7295157664148372495, 1196016433265952743),
    (7982903447895485668, 1913626293225524389),
    (10075671573058298858, 1530901034580419511),
    (4371188443704728763, 1224720827664335609),
    (14372599139411386667, 1959553324262936974),
    (15187428126271019657, 1567642659410349579),
    (15839291315758726049, 1254114127528279663),
    (3206773216762499739, 2006582604045247462),
    (13633465017635730761, 1605266083236197969),
    (14596120828850494932, 1284212866588958375),
    (4907049252451240275, 2054740586542333401),
    (236290587219081897, 1643792469233866721),
    (14946427728742906810, 1315033975387093376),
    (16535586736504830250, 2104054360619349402),
    (5849771759720043554, 1683243488495479522),
    (15747863852001765813, 1346594790796383617),
    (10439186904235184007, 2154551665274213788),
    (15730047152871967852, 1723641332219371030),
    (12584037722297574282, 1378913065775496824),
    (9066413911450387881, 2206260905240794919),
    (10942479943902220628, 1765008724192635935),
    (8753983955121776503, 1412006979354108748),
    (10317025513452932081, 2259211166966573997),
    (874922781278525018, 1807368933573259198),
    (8078635854506640661, 1445895146858607358),
    (13841606313089133175, 1156716117486885886),
    (14767872471458792434, 1850745787979017418),
    (746251532941302978, 1480596630383213935),
    (597001226353042382, 1184477304306571148),
    (15712597221132509104, 1895163686890513836),
    (8880728962164096960, 1516130949512411069),
    (10793931984473187891, 1212904759609928855),
    (17270291175157100626, 1940647615375886168),
    (2748186495899949531, 1552518092300708935),
    (2198549196719959625, 1242014473840567148),
    (18275073973719576693, 1987223158144907436),
    (10930710364233751031, 1589778526515925949),
    (12433917106128911148, 1271822821212740759),
    (8826220925580526867, 2034916513940385215),
    (7060976740464421494, 1627933211152308172),
    (16716827836597268165, 1302346568921846537),
    (11989529279587987770, 2083754510274954460),
    (9591623423670390216, 1667003608219963568),
    (15051996368420132820, 1333602886575970854),
    (13015147745246481542, 2133764618521553367),
    (3033420566713364587, 1707011694817242694),
    (6116085268112601993, 1365609355853794155),
    (9785736428980163188, 2184974969366070648),
    (15207286772667951197, 1747979975492856518),
    (1097782973908629988, 1398383980394285215),
    (1756452758253807981, 2237414368630856344),
    (5094511021344956708, 1789931494904685075),
    (4075608817075965366, 1431945195923748060),
    (6520974107321544586, 2291112313477996896),
    (1527430471115325346, 1832889850782397517),
    (12289990821117991246, 1466311880625918013),
    (17210690286378213644, 1173049504500734410),
    (9090360384495590213, 1876879207201175057),
    (18340334751822203140, 1501503365760940045),
    (14672267801457762512, 1201202692608752036),
    (16096930852848599373, 1921924308174003258),
    (1809498238053148529, 1537539446539202607),
    (12515645034668249793, 1230031557231362085),
    (1578287981759648052, 1968050491570179337),
    (12330676829633449412, 1574440393256143469),
    (13553890278448669853, 1259552314604914775),
    (3239480371808320148, 2015283703367863641),
    (17348979556414297411, 1612226962694290912),
    (6500486015647617283, 1289781570155432730),
    (10400777625036187652, 2063650512248692368),
    (15699319729512770768, 1650920409798953894),
    (16248804598352126938, 1320736327839163115),
    (7551343283653851484, 2113178124542660985),
    (6041074626923081187, 1690542499634128788),
    (12211557331022285596, 1352433999707303030),
    (1091747655926105338, 2163894399531684849),
    (4562746939482794594, 1731115519625347879),
    (7339546366328145998, 1384892415700278303),
    (8053925371383123274, 2215827865120445285),
    (6443140297106498619, 1772662292096356228),
    (12533209867169019542, 1418129833677084982),
    (5295740528502789974, 2269007733883335972),
    (15304638867027962949, 1815206187106668777),
    (4865013464138549713, 1452164949685335022),
    (14960057215536570740, 1161731959748268017),
    (9178696285890871890, 1858771135597228828),
    (14721654658196518159, 1487016908477783062),
    (4398626097073393881, 1189613526782226450),
    (7037801755317430209, 1903381642851562320),
    (5630241404253944167, 1522705314281249856),
    (814844308661245011, 1218164251424999885),
    (1303750893857992017, 1949062802279999816),
    (15800395974054034906, 1559250241823999852),
    (5261619149759407279, 1247400193459199882),
    (12107939454356961969, 1995840309534719811),
    (5997002748743659252, 1596672247627775849),
    (8486951013736837725, 1277337798102220679),
    (2511075177753209390, 2043740476963553087),
    (13076906586428298482, 1634992381570842469),
    (14150874083884549109, 1307993905256673975),
    (4194654460505726958, 2092790248410678361),
    (18113118827372222859, 1674232198728542688),
    (3422448617672047318, 1339385758982834151),
    (16543964232501006678, 2143017214372534641),
    (9545822571258895019, 1714413771498027713),
    (15015355686490936662, 1371531017198422170),
    (5577825024675947042, 2194449627517475473),
    (11840957649224578280, 1755559702013980378),
    (16851463748863483271, 1404447761611184302),
    (12204946739213931940, 2247116418577894884),
    (13453306206113055875, 1797693134862315907),
    (3383947335406624054, 1438154507889852726),
    (16482362180876329456, 2301047212623764361),
    (9496540929959153242, 1840837770099011489),
    (11286581558709232917, 1472670216079209191),
    (5339916432225476010, 1178136172863367353),
    (4854517476818851293, 1885017876581387765),
    (3883613981455081034, 1508014301265110212),
    (14174937629389795797, 1206411441012088169),
    (11611853762797942306, 1930258305619341071),
    (5600134195496443521, 1544206644495472857),
    (15548153800622885787, 1235365315596378285),
    (6430302007287065643, 1976584504954205257),
    (16212288050055383484, 1581267603963364205),
    (12969830440044306787, 1265014083170691364),
    (9683682259845159889, 2024022533073106183),
    (15125643437359948558, 1619218026458484946),
    (8411165935146048523, 1295374421166787957),
    (17147214310975587960, 2072599073866860731),
    (10028422634038560045, 1658079259093488585),
    (8022738107230848036, 1326463407274790868),
    (9147032156827446534, 2122341451639665389),
    (11006974540203867551, 1697873161311732311),
    (5116230817421183718, 1358298529049385849),
    (15564666937357714594, 2173277646479017358),
    (1383687105660440706, 1738622117183213887),
    (12174996128754083534, 1390897693746571109),
    (8411947361780802685, 2225436309994513775),
    (6729557889424642148, 1780349047995611020),
    (5383646311539713719, 1424279238396488816),
    (1235136468979721303, 2278846781434382106),
    (15745504434151418335, 1823077425147505684),
    (16285752362063044992, 1458461940118004547),
    (5649904260166615347, 1166769552094403638),
    (5350498001524674232, 1866831283351045821),
    (591049586477829062, 1493465026680836657),
    (11540886113407994219, 1194772021344669325),
    (18673707743239135, 1911635234151470921),
    (14772334225162232601, 1529308187321176736),
    (8128518565387875758, 1223446549856941389),
    (1937583260394870242, 1957514479771106223),
    (8928764237799716840, 1566011583816884978),
    (14521709019723594119, 1252809267053507982),
    (8477339172590109297, 2004494827285612772),
    (17849917782297818407, 1603595861828490217),
    (6901236596354434079, 1282876689462792174),
    (18420676183650915173, 2052602703140467478),
    (3668494502695001169, 1642082162512373983),
    (10313493231639821582, 1313665730009899186),
    (9122891541139893884, 2101865168015838698),
    (14677010862395735754, 1681492134412670958),
    (673562245690857633, 1345193707530136767),
];

pub static DOUBLE_POW5_SPLIT: [(u64, u64); 326] = [
    (0, 1152921504606846976),
    (0, 1441151880758558720),
    (0, 1801439850948198400),
    (0, 2251799813685248000),
    (0, 1407374883553280000),
    (0, 1759218604441600000),
    (0, 2199023255552000000),
    (0, 1374389534720000000),
    (0, 1717986918400000000),
    (0, 2147483648000000000),
    (0, 1342177280000000000),
    (0, 1677721600000000000),
    (0, 2097152000000000000),
    (0, 1310720000000000000),
    (0, 1638400000000000000),
    (0, 2048000000000000000),
    (0, 1280000000000000000),
    (0, 1600000000000000000),
    (0, 2000000000000000000),
    (0, 1250000000000000000),
    (0, 1562500000000000000),
    (0, 1953125000000000000),
    (0, 1220703125000000000),
    (0, 1525878906250000000),
    (0, 1907348632812500000),
    (0, 1192092895507812500),
    (0, 1490116119384765625),
    (4611686018427387904, 1862645149230957031),
    (9799832789158199296, 1164153218269348144),
    (12249790986447749120, 1455191522836685180),
    (15312238733059686400, 1818989403545856475),
    (14528612397897220096, 2273736754432320594),
    (13692068767113150464, 1421085471520200371),
    (12503399940464050176, 1776356839400250464),
    (15629249925580062720, 2220446049250313080),
    (9768281203487539200, 1387778780781445675),
    (7598665485932036096, 1734723475976807094),
    (274959820560269312, 2168404344971008868),
    (9395221924704944128, 1355252715606880542),
    (2520655369026404352, 1694065894508600678),
    (12374191248137781248, 2117582368135750847),
    (14651398557727195136, 1323488980084844279),
    (13702562178731606016, 1654361225106055349),
    (3293144668132343808, 2067951531382569187),
    (18199116482078572544, 1292469707114105741),
    (8913837547316051968, 1615587133892632177),
    (15753982952572452864, 2019483917365790221),
    (12152082354571476992, 1262177448353618888),
    (15190102943214346240, 1577721810442023610),
    (9764256642163156992, 1972152263052529513),
    (17631875447420442880, 1232595164407830945),
    (8204786253993389888, 1540743955509788682),
    (1032610780636961552, 1925929944387235853),
    (2951224747111794922, 1203706215242022408),
    (3689030933889743652, 1504632769052528010),
    (13834660704216955373, 1880790961315660012),
    (17870034976990372916, 1175494350822287507),
    (17725857702810578241, 1469367938527859384),
    (3710578054803671186, 1836709923159824231),
    (26536550077201078, 2295887403949780289),
    (11545800389866720434, 1434929627468612680),
    (14432250487333400542, 1793662034335765850),
    (8816941072311974870, 2242077542919707313),
    (17039803216263454053, 1401298464324817070),
    (12076381983474541759, 1751623080406021338),
    (5872105442488401391, 2189528850507526673),
    (15199280947623720629, 1368455531567204170),
    (9775729147674874978, 1710569414459005213),
    (16831347453020981627, 2138211768073756516),
    (1296220121283337709, 1336382355046097823),
    (15455333206886335848, 1670477943807622278),
    (10095794471753144002, 2088097429759527848),
    (6309871544845715001, 1305060893599704905),
    (12499025449484531656, 1631326116999631131),
    (11012095793428276666, 2039157646249538914),
    (11494245889320060820, 1274473528905961821),
    (532749306367912313, 1593091911132452277),
    (5277622651387278295, 1991364888915565346),
    (7910200175544436838, 1244603055572228341),
    (14499436237857933952, 1555753819465285426),
    (8900923260467641632, 1944692274331606783),
    (12480606065433357876, 1215432671457254239),
    (10989071563364309441, 1519290839321567799),
    (9124653435777998898, 1899113549151959749),
    (8008751406574943263, 1186945968219974843),
    (5399253239791291175, 1483682460274968554),
    (15972438586593889776, 1854603075343710692),
    (759402079766405302, 1159126922089819183),
    (14784310654990170340, 1448908652612273978),
    (9257016281882937117, 1811135815765342473),
    (16182956370781059300, 2263919769706678091),
    (7808504722524468110, 1414949856066673807),
    (5148944884728197234, 1768687320083342259),
    (1824495087482858639, 2210859150104177824),
    (1140309429676786649, 1381786968815111140),
    (1425386787095983311, 1727233711018888925),
    (6393419502297367043, 2159042138773611156),
    (13219259225790630210, 1349401336733506972),
    (16524074032238287762, 1686751670916883715),
    (16043406521870471799, 2108439588646104644),
    (803757039314269066, 1317774742903815403),
    (14839754354425000045, 1647218428629769253),
    (4714634887749086344, 2059023035787211567),
    (9864175832484260821, 1286889397367007229),
    (16941905809032713930, 1608611746708759036),
    (2730638187581340797, 2010764683385948796),
    (10930020904093113806, 1256727927116217997),
    (18274212148543780162, 1570909908895272496),
    (4396021111970173586, 1963637386119090621),
    (5053356204195052443, 1227273366324431638),
    (15540067292098591362, 1534091707905539547),
    (14813398096695851299, 1917614634881924434),
    (13870059828862294966, 1198509146801202771),
    (12725888767650480803, 1498136433501503464),
    (15907360959563101004, 1872670541876879330),
    (14553786618154326031, 1170419088673049581),
    (4357175217410743827, 1463023860841311977),
    (10058155040190817688, 1828779826051639971),
    (7961007781811134206, 2285974782564549964),
    (14199001900486734687, 1428734239102843727),
    (13137066357181030455, 1785917798878554659),
    (11809646928048900164, 2232397248598193324),
    (16604401366885338411, 1395248280373870827),
    (16143815690179285109, 1744060350467338534),
    (10956397575869330579, 2180075438084173168),
    (6847748484918331612, 1362547148802608230),
    (17783057643002690323, 1703183936003260287),
    (17617136035325974999, 2128979920004075359),
    (17928239049719816230, 1330612450002547099),
    (17798612793722382384, 1663265562503183874),
    (13024893955298202172, 2079081953128979843),
    (5834715712847682405, 1299426220705612402),
    (16516766677914378815, 1624282775882015502),
    (11422586310538197711, 2030353469852519378),
    (11750802462513761473, 1268970918657824611),
    (10076817059714813937, 1586213648322280764),
    (12596021324643517422, 1982767060402850955),
    (5566670318688504437, 1239229412751781847),
    (2346651879933242642, 1549036765939727309),
    (7545000868343941206, 1936295957424659136),
    (4715625542714963254, 1210184973390411960),
    (5894531928393704067, 1512731216738014950),
    (16591536947346905892, 1890914020922518687),
    (17287239619732898039, 1181821263076574179),
    (16997363506238734644, 1477276578845717724),
    (2799960309088866689, 1846595723557147156),
    (10973347230035317489, 1154122327223216972),
    (13716684037544146861, 1442652909029021215),
    (12534169028502795672, 1803316136286276519),
    (11056025267201106687, 2254145170357845649),
    (18439230838069161439, 1408840731473653530),
    (13825666510731675991, 1761050914342066913),
    (3447025083132431277, 2201313642927583642),
    (6766076695385157452, 1375821026829739776),
    (8457595869231446815, 1719776283537174720),
    (10571994836539308519, 2149720354421468400),
    (6607496772837067824, 1343575221513417750),
    (17482743002901110588, 1679469026891772187),
    (17241742735199000331, 2099336283614715234),
    (15387775227926763111, 1312085177259197021),
    (5399660979626290177, 1640106471573996277),
    (11361262242960250625, 2050133089467495346),
    (11712474920277544544, 1281333180917184591),
    (10028907631919542777, 1601666476146480739),
    (7924448521472040567, 2002083095183100924),
    (14176152362774801162, 1251301934489438077),
    (3885132398186337741, 1564127418111797597),
    (9468101516160310080, 1955159272639746996),
    (15140935484454969608, 1221974545399841872),
    (479425281859160394, 1527468181749802341),
    (5210967620751338397, 1909335227187252926),
    (17091912818251750210, 1193334516992033078),
    (12141518985959911954, 1491668146240041348),
    (15176898732449889943, 1864585182800051685),
    (11791404716994875166, 1165365739250032303),
    (10127569877816206054, 1456707174062540379),
    (8047776328842869663, 1820883967578175474),
    (836348374198811271, 2276104959472719343),
    (7440246761515338900, 1422565599670449589),
    (13911994470321561530, 1778206999588061986),
    (8166621051047176104, 2222758749485077483),
    (2798295147690791113, 1389224218428173427),
    (17332926989895652603, 1736530273035216783),
    (17054472718942177850, 2170662841294020979),
    (8353202440125167204, 1356664275808763112),
    (10441503050156459005, 1695830344760953890),
    (3828506775840797949, 2119787930951192363),
    (86973725686804766, 1324867456844495227),
    (13943775212390669669, 1656084321055619033),
    (3594660960206173375, 2070105401319523792),
    (2246663100128858359, 1293815875824702370),
    (12031700912015848757, 1617269844780877962),
    (5816254103165035138, 2021587305976097453),
    (5941001823691840913, 1263492066235060908),
    (7426252279614801142, 1579365082793826135),
    (4671129331091113523, 1974206353492282669),
    (5225298841145639904, 1233878970932676668),
    (6531623551432049880, 1542348713665845835),
    (3552843420862674446, 1927935892082307294),
    (16055585193321335241, 1204959932551442058),
    (10846109454796893243, 1506199915689302573),
    (18169322836923504458, 1882749894611628216),
    (11355826773077190286, 1176718684132267635),
    (9583097447919099954, 1470898355165334544),
    (11978871809898874942, 1838622943956668180),
    (14973589762373593678, 2298278679945835225),
    (2440964573842414192, 1436424174966147016),
    (3051205717303017741, 1795530218707683770),
    (13037379183483547984, 2244412773384604712),
    (8148361989677217490, 1402757983365377945),
    (14797138505523909766, 1753447479206722431),
    (13884737113477499304, 2191809349008403039),
    (15595489723564518921, 1369880843130251899),
    (14882676136028260747, 1712351053912814874),
    (9379973133180550126, 2140438817391018593),
    (17391698254306313589, 1337774260869386620),
    (3292878744173340370, 1672217826086733276),
    (4116098430216675462, 2090272282608416595),
    (266718509671728212, 1306420176630260372),
    (333398137089660265, 1633025220787825465),
    (5028433689789463235, 2041281525984781831),
    (10060300083759496378, 1275800953740488644),
    (12575375104699370472, 1594751192175610805),
    (1884160825592049379, 1993438990219513507),
    (17318501580490888525, 1245899368887195941),
    (7813068920331446945, 1557374211108994927),
    (5154650131986920777, 1946717763886243659),
    (915813323278131534, 1216698602428902287),
    (14979824709379828129, 1520873253036127858),
    (9501408849870009354, 1901091566295159823),
    (12855909558809837702, 1188182228934474889),
    (2234828893230133415, 1485227786168093612),
    (2793536116537666769, 1856534732710117015),
    (8663489100477123587, 1160334207943823134),
    (1605989338741628675, 1450417759929778918),
    (11230858710281811652, 1813022199912223647),
    (9426887369424876662, 2266277749890279559),
    (12809333633531629769, 1416423593681424724),
    (16011667041914537212, 1770529492101780905),
    (6179525747111007803, 2213161865127226132),
    (13085575628799155685, 1383226165704516332),
    (16356969535998944606, 1729032707130645415),
    (15834525901571292854, 2161290883913306769),
    (2979049660840976177, 1350806802445816731),
    (17558870131333383934, 1688508503057270913),
    (8113529608884566205, 2110635628821588642),
    (9682642023980241782, 1319147268013492901),
    (16714988548402690132, 1648934085016866126),
    (11670363648648586857, 2061167606271082658),
    (11905663298832754689, 1288229753919426661),
    (1047021068258779650, 1610287192399283327),
    (15143834390605638274, 2012858990499104158),
    (4853210475701136017, 1258036869061940099),
    (1454827076199032118, 1572546086327425124),
    (1818533845248790147, 1965682607909281405),
    (3442426662494187794, 1228551629943300878),
    (13526405364972510550, 1535689537429126097),
    (3072948650933474476, 1919611921786407622),
    (15755650962115585259, 1199757451116504763),
    (15082877684217093670, 1499696813895630954),
    (9630225068416591280, 1874621017369538693),
    (8324733676974063502, 1171638135855961683),
    (5794231077790191473, 1464547669819952104),
    (7242788847237739342, 1830684587274940130),
    (18276858095901949986, 2288355734093675162),
    (16034722328366106645, 1430222333808546976),
    (1596658836748081690, 1787777917260683721),
    (6607509564362490017, 2234722396575854651),
    (1823850468512862308, 1396701497859909157),
    (6891499104068465790, 1745876872324886446),
    (17837745916940358045, 2182346090406108057),
    (4231062170446641922, 1363966306503817536),
    (5288827713058302403, 1704957883129771920),
    (6611034641322878003, 2131197353912214900),
    (13355268687681574560, 1331998346195134312),
    (16694085859601968200, 1664997932743917890),
    (11644235287647684442, 2081247415929897363),
    (4971804045566108824, 1300779634956185852),
    (6214755056957636030, 1625974543695232315),
    (3156757802769657134, 2032468179619040394),
    (6584659645158423613, 1270292612261900246),
    (17454196593302805324, 1587865765327375307),
    (17206059723201118751, 1984832206659219134),
    (6142101308573311315, 1240520129162011959),
    (3065940617289251240, 1550650161452514949),
    (8444111790038951954, 1938312701815643686),
    (665883850346957067, 1211445438634777304),
    (832354812933696334, 1514306798293471630),
    (10263815553021896226, 1892883497866839537),
    (17944099766707154901, 1183052186166774710),
    (13206752671529167818, 1478815232708468388),
    (16508440839411459773, 1848519040885585485),
    (12623618533845856310, 1155324400553490928),
    (15779523167307320387, 1444155500691863660),
    (1277659885424598868, 1805194375864829576),
    (1597074856780748586, 2256492969831036970),
    (5609857803915355770, 1410308106144398106),
    (16235694291748970521, 1762885132680497632),
    (1847873790976661535, 2203606415850622041),
    (12684136165428883219, 1377254009906638775),
    (11243484188358716120, 1721567512383298469),
    (219297180166231438, 2151959390479123087),
    (7054589765244976505, 1344974619049451929),
    (13429923224983608535, 1681218273811814911),
    (12175718012802122765, 2101522842264768639),
    (14527352785642408584, 1313451776415480399),
    (13547504963625622826, 1641814720519350499),
    (12322695186104640628, 2052268400649188124),
    (16925056528170176201, 1282667750405742577),
    (7321262604930556539, 1603334688007178222),
    (18374950293017971482, 2004168360008972777),
    (4566814905495150320, 1252605225005607986),
    (14931890668723713708, 1565756531257009982),
    (9441491299049866327, 1957195664071262478),
    (1289246043478778550, 1223247290044539049),
    (6223243572775861092, 1529059112555673811),
    (3167368447542438461, 1911323890694592264),
    (1979605279714024038, 1194577431684120165),
    (7086192618069917952, 1493221789605150206),
    (18081112809442173248, 1866527237006437757),
    (13606538515115052232, 1166579523129023598),
    (7784801107039039482, 1458224403911279498),
    (507629346944023544, 1822780504889099373),
    (5246222702107417334, 2278475631111374216),
    (3278889188817135834, 1424047269444608885),
    (8710297504448807696, 1780059086805761106),
];
