
import Foundation
import UIKit

// each type has its own random

public extension Bool {
    /// SwiftRandom extension
    public static func random() -> Bool {
        return Int.random() % 2 == 0
    }
}

public extension Int {
    public static func random(range: Range<Int>) -> Int {
        return random(range.startIndex, range.endIndex)
    }

    public static func random(lower: Int = 0, _ upper: Int = 100) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower)))
    }
}

public extension Int32 {
    /// SwiftRandom extension
    public static func random(range: Range<Int>) -> Int32 {
        return random(range.endIndex, range.startIndex)
    }

    /// SwiftRandom extension
    ///
    /// - note: Using `Int` as parameter type as we usually just want to write `Int32.random(13, 37)` and not `Int32.random(Int32(13), Int32(37))`
    public static func random(lower: Int = 0, _ upper: Int = 100) -> Int32 {
        let r = arc4random_uniform(UInt32(Int64(upper) - Int64(lower)))
        return Int32(Int64(r) + Int64(lower))
    }
}

public extension Double {
    /// SwiftRandom extension
    public static func random(lower: Double = 0, _ upper: Double = 100) -> Double {
        return (Double(arc4random()) / 0xFFFFFFFF) * (upper - lower) + lower
    }
}

public extension Float {
    /// SwiftRandom extension
    public static func random(lower: Float = 0, _ upper: Float = 100) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (upper - lower) + lower
    }
}

public extension CGFloat {
    /// SwiftRandom extension
    public static func random(lower: CGFloat = 0, _ upper: CGFloat = 1) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (upper - lower) + lower
    }
}

public extension NSDate {
    /// SwiftRandom extension
    public static func randomWithinDaysBeforeToday(days: Int) -> NSDate {
        let today = NSDate()

        guard let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian) else {
            print("no calendar \"NSCalendarIdentifierGregorian\" found")
            return today
        }

        let r1 = arc4random_uniform(UInt32(days))
        let r2 = arc4random_uniform(UInt32(23))
        let r3 = arc4random_uniform(UInt32(59))
        let r4 = arc4random_uniform(UInt32(59))

        let offsetComponents = NSDateComponents()
        offsetComponents.day = Int(r1) * -1
        offsetComponents.hour = Int(r2)
        offsetComponents.minute = Int(r3)
        offsetComponents.second = Int(r4)

        guard let rndDate1 = gregorian.dateByAddingComponents(offsetComponents, toDate: today, options: []) else {
            print("randoming failed")
            return today
        }
        return rndDate1
    }

    /// SwiftRandom extension
    public static func random() -> NSDate {
        let randomTime = NSTimeInterval(arc4random_uniform(UInt32.max))
        return NSDate(timeIntervalSince1970: randomTime)
    }

}

public extension UIColor {
    /// SwiftRandom extension
    public static func random(randomAlpha: Bool = false) -> UIColor {
        let randomRed = CGFloat.random()
        let randomGreen = CGFloat.random()
        let randomBlue = CGFloat.random()
        let alpha = randomAlpha ? CGFloat.random() : 1.0
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: alpha)
    }
}

public extension Array {
    /// SwiftRandom extension
    public func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

public extension ArraySlice {
    /// SwiftRandom extension
    public func randomItem() -> Element {
        let index = Int.random(self.startIndex..<self.endIndex)
        return self[index]
    }
}

public extension NSURL {
    /// SwiftRandom extension
    public static func random() -> NSURL {
        let urlList = ["http://www.google.com", "http://leagueoflegends.com/", "https://github.com/", "http://stackoverflow.com/", "https://medium.com/", "http://9gag.com/gag/6715049", "http://imgur.com/gallery/s9zoqs9", "https://www.youtube.com/watch?v=uelHwf8o7_U"]
        return NSURL(string: urlList.randomItem())!
    }
}


public struct Randoms {

    //==========================================================================================================
    // MARK: - Object randoms
    //==========================================================================================================

    public static func randomBool() -> Bool {
        return Bool.random()
    }

    public static func randomInt(range: Range<Int>) -> Int {
        return Int.random(range)
    }

    public static func randomInt(lower: Int = 0, _ upper: Int = 100) -> Int {
        return Int.random(lower, upper)
    }

    public static func randomInt32(range: Range<Int>) -> Int32 {
        return Int32.random(range)
    }

    public static func randomInt32(lower: Int = 0, _ upper: Int = 100) -> Int32{
        return Int32.random(lower, upper)
    }

    public static func randomPercentageisOver(percentage: Int) -> Bool {
        return Int.random() > percentage
    }

    public static func randomDouble(lower: Double = 0, _ upper: Double = 100) -> Double {
        return Double.random(lower, upper)
    }

    public static func randomFloat(lower: Float = 0, _ upper: Float = 100) -> Float {
        return Float.random(lower, upper)
    }

    public static func randomCGFloat(lower: CGFloat = 0, _ upper: CGFloat = 1) -> CGFloat {
        return CGFloat.random(lower, upper)
    }

    public static func randomDateWithinDaysBeforeToday(days: Int) -> NSDate {
        return NSDate.randomWithinDaysBeforeToday(days)
    }

    public static func randomDate() -> NSDate {
        return NSDate.random()
    }

    public static func randomColor(randomAlpha: Bool = false) -> UIColor {
        return UIColor.random(randomAlpha)
    }

    public static func randomNSURL() -> NSURL {
        return NSURL.random()
    }

    //==========================================================================================================
    // MARK: - Fake random data generators
    //==========================================================================================================


    public static func randomFakeGroupName() -> String {
        return ["Group 1","Group 2","Group 3","Group 4","Group 5"].randomItem()
    }

    public static func randomFakeCreatureNames() -> String {
        return creatureNames().randomItem()
    }


    public static func creatureNames() -> [String] {
        return ["SquidWard","Sumbrao","Blob","Busheeks","Terminator","#ImgettindizzyFrom", "Barney","Purple cabbage","Da rock","Miranda Shouts","Spotted Ninjas","SmartHulk","MonsterMash","JabberJaw"]
    }


    public static func randomFakeName() -> String {
        return randomFakeFirstName() + " " + randomFakeLastName()
    }

    public static func randomFakeFirstName() -> String {
        return firstNames().randomItem()
    }

    public static func randomFakeLastName() -> String {
        return lastNames().randomItem()
    }

    private static func lastNames() -> [String] {
            return "Abbott,Abernathy,Abshire,Adams,Altenwerth,Anderson,Ankunding,Armstrong,Auer,Aufderhar,Bahringer,Bailey,Balistreri,Barrows,Bartell,Bartoletti,Barton,Bashirian,Batz,Bauch,Baumbach,Bayer,Beahan,Beatty,Bechtelar,Becker,Bednar,Beer,Beier,Berge,Bergnaum,Bergstrom,Bernhard,Bernier,Bins,Blanda,Blick,Block,Bode,Boehm,Bogan,Bogisich,Borer,Bosco,Botsford,Boyer,Boyle,Bradtke,Brakus,Braun,Breitenberg,Brekke,Brown,Bruen,Buckridge,Carroll,Carter,Cartwright,Casper,Cassin,Champlin,Christiansen,Cole,Collier,Collins,Conn,Connelly,Conroy,Considine,Corkery,Cormier,Corwin,Cremin,Crist,Crona,Cronin,Crooks,Cruickshank,Cummerata,Cummings,Dach,D'Amore,Daniel,Dare,Daugherty,Davis,Deckow,Denesik,Dibbert,Dickens,Dicki,Dickinson,Dietrich,Donnelly,Dooley,Douglas,Doyle,DuBuque,Durgan,Ebert,Effertz,Eichmann,Emard,Emmerich,Erdman,Ernser,Fadel,Fahey,Farrell,Fay,Feeney,Feest,Feil,Ferry,Fisher,Flatley,Frami,Franecki,Friesen,Fritsch,Funk,Gaylord,Gerhold,Gerlach,Gibson,Gislason,Gleason,Gleichner,Glover,Goldner,Goodwin,Gorczany,Gottlieb,Goyette,Grady,Graham,Grant,Green,Greenfelder,Greenholt,Grimes,Gulgowski,Gusikowski,Gutkowski,Gutmann,Haag,Hackett,Hagenes,Hahn,Haley,Halvorson,Hamill,Hammes,Hand,Hane,Hansen,Harber,Harris,Hartmann,Harvey,Hauck,Hayes,Heaney,Heathcote,Hegmann,Heidenreich,Heller,Herman,Hermann,Hermiston,Herzog,Hessel,Hettinger,Hickle,Hilll,Hills,Hilpert,Hintz,Hirthe,Hodkiewicz,Hoeger,Homenick,Hoppe,Howe,Howell,Hudson,Huel,Huels,Hyatt,Jacobi,Jacobs,Jacobson,Jakubowski,Jaskolski,Jast,Jenkins,Jerde,Johns,Johnson,Johnston,Jones,Kassulke,Kautzer,Keebler,Keeling,Kemmer,Kerluke,Kertzmann,Kessler,Kiehn,Kihn,Kilback,King,Kirlin,Klein,Kling,Klocko,Koch,Koelpin,Koepp,Kohler,Konopelski,Koss,Kovacek,Kozey,Krajcik,Kreiger,Kris,Kshlerin,Kub,Kuhic,Kuhlman,Kuhn,Kulas,Kunde,Kunze,Kuphal,Kutch,Kuvalis,Labadie,Lakin,Lang,Langosh,Langworth,Larkin,Larson,Leannon,Lebsack,Ledner,Leffler,Legros,Lehner,Lemke,Lesch,Leuschke,Lind,Lindgren,Littel,Little,Lockman,Lowe,Lubowitz,Lueilwitz,Luettgen,Lynch,Macejkovic,Maggio,Mann,Mante,Marks,Marquardt,Marvin,Mayer,Mayert,McClure,McCullough,McDermott,McGlynn,McKenzie,McLaughlin,Medhurst,Mertz,Metz,Miller,Mills,Mitchell,Moen,Mohr,Monahan,Moore,Morar,Morissette,Mosciski,Mraz,Mueller,Muller,Murazik,Murphy,Murray,Nader,Nicolas,Nienow,Nikolaus,Nitzsche,Nolan,Oberbrunner,O'Connell,O'Conner,O'Hara,O'Keefe,O'Kon,Okuneva,Olson,Ondricka,O'Reilly,Orn,Ortiz,Osinski,Pacocha,Padberg,Pagac,Parisian,Parker,Paucek,Pfannerstill,Pfeffer,Pollich,Pouros,Powlowski,Predovic,Price,Prohaska,Prosacco,Purdy,Quigley,Quitzon,Rath,Ratke,Rau,Raynor,Reichel,Reichert,Reilly,Reinger,Rempel,Renner,Reynolds,Rice,Rippin,Ritchie,Robel,Roberts,Rodriguez,Rogahn,Rohan,Rolfson,Romaguera,Roob,Rosenbaum,Rowe,Ruecker,Runolfsdottir,Runolfsson,Runte,Russel,Rutherford,Ryan,Sanford,Satterfield,Sauer,Sawayn,Schaden,Schaefer,Schamberger,Schiller,Schimmel,Schinner,Schmeler,Schmidt,Schmitt,Schneider,Schoen,Schowalter,Schroeder,Schulist,Schultz,Schumm,Schuppe,Schuster,Senger,Shanahan,Shields,Simonis,Sipes,Skiles,Smith,Smitham,Spencer,Spinka,Sporer,Stamm,Stanton,Stark,Stehr,Steuber,Stiedemann,Stokes,Stoltenberg,Stracke,Streich,Stroman,Strosin,Swaniawski,Swift,Terry,Thiel,Thompson,Tillman,Torp,Torphy,Towne,Toy,Trantow,Tremblay,Treutel,Tromp,Turcotte,Turner,Ullrich,Upton,Vandervort,Veum,Volkman,Von,VonRueden,Waelchi,Walker,Walsh,Walter,Ward,Waters,Watsica,Weber,Wehner,Weimann,Weissnat,Welch,West,White,Wiegand,Wilderman,Wilkinson,Will,Williamson,Willms,Windler,Wintheiser,Wisoky,Wisozk,Witting,Wiza,Wolf,Wolff,Wuckert,Wunsch,Wyman,Yost,Yundt,Zboncak,Zemlak,Ziemann,Zieme,Zulauf".componentsSeparatedByString(",")
    }


    private static func firstNames() -> [String] {
            return "Aaron,Abdiel,Abdul,Abdullah,Abe,Abel,Abelardo,Abner,Abraham,Adalberto,Adam,Adan,Adelbert,Adolf,Adolfo,Adolph,Adolphus,Adonis,Adrain,Adrian,Adriel,Adrien,Afton,Agustin,Ahmad,Ahmed,Aidan,Aiden,Akeem,Al,Alan,Albert,Alberto,Albin,Alden,Alec,Alejandrin,Alek,Alessandro,Alex,Alexander,Alexandre,Alexandro,Alexie,Alexis,Alexys,Alexzander,Alf,Alfonso,Alfonzo,Alford,Alfred,Alfredo,Ali,Allan,Allen,Alphonso,Alvah,Alvis,Amani,Amari,Ambrose,Americo,Amir,Amos,Amparo,Anastacio,Anderson,Andre,Andres,Andrew,Andy,Angel,Angelo,Angus,Anibal,Ansel,Ansley,Anthony,Antone,Antonio,Antwan,Antwon,Arch,Archibald,Arden,Arely,Ari,Aric,Ariel,Arjun,Arlo,Armand,Armando,Armani,Arnaldo,Arne,Arno,Arnold,Arnoldo,Arnulfo,Aron,Art,Arthur,Arturo,Arvel,Arvid,Ashton,August,Augustus,Aurelio,Austen,Austin,Austyn,Avery,Axel,Ayden,Bailey,Barney,Baron,Barrett,Barry,Bart,Bartholome,Barton,Baylee,Beau,Bell,Ben,Benedict,Benjamin,Bennett,Bennie,Benny,Benton,Bernard,Bernardo,Bernhard,Bernie,Berry,Berta,Bertha,Bertram,Bertrand,Bill,Billy,Blair,Blaise,Blake,Blaze,Bo,Bobbie,Bobby,Boris,Boyd,Brad,Braden,Bradford,Bradley,Bradly,Brady,Braeden,Brain,Brando,Brandon,Brandt,Brannon,Branson,Brant,Braulio,Braxton,Brayan,Brendan,Brenden,Brendon,Brennan,Brennon,Brent,Bret,Brett,Brian,Brice,Brock,Broderick,Brody,Brook,Brooks,Brown,Bruce,Bryce,Brycen,Bryon,Buck,Bud,Buddy,Buford,Burley,Buster,Cade,Caden,Caesar,Cale,Caleb,Camden,Cameron,Camren,Camron,Camryn,Candelario,Candido,Carey,Carleton,Carlo,Carlos,Carmel,Carmelo,Carmine,Carol,Carroll,Carson,Carter,Cary,Casey,Casimer,Casimir,Casper,Ceasar,Cecil,Cedrick,Celestino,Cesar,Chad,Chadd,Chadrick,Chaim,Chance,Chandler,Charles,Charley,Charlie,Chase,Chauncey,Chaz,Chelsey,Chesley,Chester,Chet,Chris,Christ,Christian,Christop,Christophe,Christopher,Cicero,Cielo,Clair,Clark,Claud,Claude,Clay,Clemens,Clement,Cleo,Cletus,Cleve,Cleveland,Clifford,Clifton,Clint,Clinton,Clovis,Cloyd,Clyde,Coby,Cody,Colby,Cole,Coleman,Colin,Collin,Colt,Colten,Colton,Columbus,Conner,Connor,Conor,Conrad,Constantin,Consuelo,Cooper,Corbin,Cordelia,Cordell,Cornelius,Cornell,Cortez,Cory,Coty,Coy,Craig,Crawford,Cristian,Cristina,Cristobal,Cristopher,Cruz,Cullen,Curt,Curtis,Cyril,Cyrus,Dagmar,Dale,Dallas,Dallin,Dalton,Dameon,Damian,Damien,Damion,Damon,Dan,Dane,D'angelo,Dangelo,Danial,Danny,Dante,Daren,Darian,Darien,Dario,Darion,Darius,Daron,Darrel,Darrell,Darren,Darrick,Darrin,Darrion,Darron,Darryl,Darwin,Daryl,Dashawn,Dave,David,Davin,Davion,Davon,Davonte,Dawson,Dax,Dayne,Dayton,Dean,Deangelo,Declan,Dedric,Dedrick,Dee,Deion,Dejon,Dejuan,Delaney,Delbert,Dell',Delmer,Demarco,Demarcus,Demario,Demetrius,Demond,Denis,Dennis,Deon,Deondre,Deontae,Deonte,Dereck,Derek,Derick,Deron,Derrick,Deshaun,Deshawn,Desmond,Destin,Devan,Devante,Deven,Devin,Devon,Devonte,Devyn,Dewayne,Dewitt,Dexter,Diamond,Diego,Dillan,Dillon,Dimitri,Dino,Dion,Dock',Domenic,Domenick,Domenico,Domingo,Dominic,Don,Donald,Donato,Donavon,Donnell,Donnie,Donny,Dorcas,Dorian,Doris,Dorthy,Doug,Douglas,Doyle,Drake,Dudley,Duncan,Durward,Dustin,Dusty,Dwight,Dylan,Earl,Earnest,Easter,Easton,Ed,Edd,Eddie,Edgar,Edgardo,Edison,Edmond,Edmund,Eduardo,Edward,Edwardo,Edwin,Efrain,Efren,Einar,Eino,Eladio,Elbert,Eldon,Eldred,Eleazar,Eli,Elian,Elias,Eliezer,Elijah,Eliseo,Elliot,Elliott,Ellis,Ellsworth,Elmer,Elmo,Elmore,Eloy,Elroy,Elton,Elvis,Elwin,Elwyn,Emanuel,Emerald,Emerson,Emery,Emil,Emile,Emiliano,Emilio,Emmanuel,Emmet,Emmett,Emmitt,Emory,Enid,Enoch,Enos,Enrico,Enrique,Ephraim,Eriberto,Eric,Erich,Erick,Erik,Erin,Erling,Ernest,Ernesto,Ernie,Ervin,Erwin,Esteban,Estevan,Ethan,Ethel,Eugene,Eusebio,Evan,Evans,Everardo,Everett,Evert,Ewald,Ewell,Ezekiel,Ezequiel,Ezra,Fabian,Faustino,Fausto,Favian,Federico,Felipe,Felix,Felton,Fermin,Fern,Fernando,Ferne,Fidel,Filiberto',  'Finn,Flavio',Fletcher,Florencio,Florian,Floy,Floyd,Ford,Forest,Forrest,Foster,Francesco,Francis,Francisco,Franco,Frank,Frankie,Franz,Fred,Freddie,Freddy,Frederic,Frederick,Frederik,Fredrick,Fredy,Freeman,Friedrich,Fritz,Furman,Gabe,Gabriel,Gaetano,Gage,Gardner,Garett,Garfield,Garland,Garnet,Garnett,Garret,Garrett,Garrick,Garrison,Garry,Garth,Gaston,Gavin,Gay,Gayle,Gaylord,Gene,General,Gennaro,Geo,Geoffrey,George,Geovanni,Geovanny,Geovany,Gerald,Gerard,Gerardo,Gerhard,German,Gerson,Gianni,Gideon,Gilbert,Gilberto,Giles,Gillian,Gino,Giovani,Giovanni,Giovanny',Giuseppe,Glen,Glennie,Godfrey,Golden,Gonzalo,Gordon,Grady,Graham,Grant,Granville,Grayce,Grayson,Green,Greg,Gregg,Gregorio,Gregory,Greyson,Griffin,Grover,Guido,Guillermo,Guiseppe,Gunnar,Gunner,Gus,Gussie,Gust,Gustave,Guy,Hadley,Hailey,Hal,Haleigh,Haley,Halle,Hank,Hans,Hardy,Harley,Harmon,Harold,Harrison,Harry,Harvey,Haskell,Hassan,Hayden,Hayley,Hazel,Hazle,Heber,Hector,Helmer,Henderson,Henri,Henry,Herbert,Herman,Hermann,Herminio,Hershel,Hester,Hilario,Hilbert,Hillard,Hilton,Hipolito,Hiram,Hobart,Holden,Hollis,Horace,Horacio,Houston,Howard,Howell,Hoyt,Hubert,Hudson,Hugh,Humberto,Hunter,Hyman,Ian,Ibrahim,Ignacio,Ignatius,Ike,Imani,Immanuel,Irving,Irwin,Isaac,Isac,Isadore,Isai,Isaiah,Isaias,Isidro,Ismael,Isom,Israel,Issac,Izaiah,Jabari,Jace,Jacey,Jacinto,Jack,Jackson,Jacques,Jaden,Jadon,Jaeden,Jaiden,Jaime,Jairo,Jake,Jakob,Jaleel,Jalen,Jalon,Jamaal,Jamal,Jamar,Jamarcus,Jamel,Jameson,Jamey,Jamie,Jamil,Jamir,Jamison,Jan,Janick,Jaquan,Jared,Jaren,Jarod,Jaron,Jarred,Jarrell,Jarret,Jarrett,Jarrod,Jarvis,Jasen,Jasmin,Jason,Jasper,Javier,Javon,Javonte,Jay,Jayce,Jaycee',  'Jayde,Jayden,Jaydon,Jaylan,Jaylen,Jaylin,Jaylon,Jayme,Jayson,Jean,Jed,Jedediah,Jedidiah,Jeff,Jefferey,Jeffery,Jeffrey,Jeffry,Jennings,Jensen,Jerad,Jerald,Jeramie,Jeramy,Jerel,Jeremie,Jeremy,Jermain,Jermey,Jerod,Jerome,Jeromy,Jerrell,Jerrod,Jerrold,Jerry,Jess,Jesse,Jessie,Jessy,Jesus,Jett,Jettie,Jevon,Jillian,Jimmie,Jimmy,Jo,Joan,Joany,Joaquin,Jocelyn,Joe,Joel',  'Joesph,Joey,Johan,Johann,Johathan,John,Johnathan,Johnathon,Johnnie,Johnny,Johnpaul,Johnson,Jon,Jonas,Jonatan,Jonathan,Jonathon,Jordan,Jordi,Jordon,Jordy,Jordyn,Jorge,Jose,Joseph,Josh,Joshua,Joshuah,Josiah,Josue,Jovan,Jovani,Jovanny,Jovany,Judah,Judd,Judge,Judson,Jules,Julian,Julien,Julio,Julius,Junior,Junius,Justen,Justice,Juston,Justus,Justyn,Juvenal,Juwan,Kacey,Kade,Kaden,Kadin,Kale,Kaleb,Kaleigh,Kaley,Kameron,Kamren,Kamron,Kamryn,Kane,Kareem,Karl,Karley,Karson,Kay,Kayden,Kayleigh,Kayley,Keagan,Keanu,Keaton,Keegan,Keeley,Keenan,Keith,Kellen,Kelley,Kelton,Kelvin,Ken,Kendall,Kendrick,Kennedi,Kennedy,Kenneth,Kennith,Kenny,Kenton,Kenyon,Keon,Keshaun,Keshawn,Keven,Kevin,Kevon,Keyon,Keyshawn,Khalid,Khalil,Kian,Kiel,Kieran,Kiley,Kim,King,Kip,Kirk,Kobe,Koby,Kody,Kolby,Kole,Korbin,Korey,Kory,Kraig,Kris,Kristian,Kristofer,Kristoffer,Kristopher,Kurt,Kurtis,Kyle,Kyleigh,Kyler,Ladarius,Lafayette,Lamar,Lambert,Lamont,Lance,Landen,Lane,Laron,Larry,Larue,Laurel,Lavern,Laverna,Laverne,Lavon,Lawrence,Lawson,Layne,Lazaro,Lee,Leif,Leland,Lemuel,Lennie,Lenny,Leo,Leon,Leonard,Leonardo,Leone,Leonel,Leopold,Leopoldo,Lesley,Lester,Levi,Lew,Lewis,Lexus,Liam,Lincoln,Lindsey,Linwood,Lionel,Lisandro,Llewellyn,Lloyd,Logan,Lon,London,Lonnie,Lonny,Lonzo,Lorenz,Lorenza,Lorenzo,Louie,Louisa,Lourdes,Louvenia,Lowell,Loy,Loyal,Lucas,Luciano,Lucio,Lucious,Lucius,Ludwig,Luigi,Luis,Lukas,Lula,Luther,Lyric,Mac,Macey,Mack,Mackenzie,Madisen,Madison,Madyson,Magnus,Major,Makenna,Malachi,Malcolm,Mallory,Manley,Manuel,Manuela,Marc,Marcel,Marcelino,Marcellus,Marcelo,Marco,Marcos,Marcus,Mariano,Mario,Mark,Markus,Marley,Marlin,Marlon,Marques,Marquis,Marshall,Martin,Marty,Marvin,Mason,Mateo,Mathew,Mathias,Matt,Matteo,Maurice,Mauricio,Maverick,Mavis,Max,Maxime,Maximilian,Maximillian,Maximo,Maximus,Maxine,Maxwell,Maynard,Mckenna,Mckenzie,Mekhi,Melany,Melvin,Melvina,Merl,Merle,Merlin,Merritt,Mervin,Micah,Michael,Michale,Micheal,Michel,Miguel,Mike,Mikel,Milan,Miles,Milford,Miller,Milo,Milton,Misael,Mitchel,Mitchell,Modesto,Mohamed,Mohammad,Mohammed,Moises,Monroe,Monserrat,Monserrate,Montana,Monte,Monty,Morgan,Moriah,Morris,Mortimer,Morton,Mose,Moses,Moshe,Muhammad,Murl,Murphy,Murray,Mustafa,Myles',  'Myrl,Myron,Napoleon,Narciso,Nash,Nasir,Nat,Nathan,Nathanael,Nathanial,Nathaniel,Nathen,Neal,Ned,Neil,Nels,Nelson,Nestor,Newell,Newton,Nicholas,Nicholaus,Nick,Nicklaus,Nickolas,Nico,Nicola,Nicolas,Nigel,Nikko,Niko,Nikolas,Nils,Noah,Noble,Noe,Noel,Nolan,Norbert,Norberto,Norris,Norval,Norwood,Obie,Oda,Odell,Okey,Ola,Olaf,Ole,Olen,Olin,Oliver,Omari,Omer,Oral,Oran,Oren,Orin,Orion,Orland,Orlando,Orlo,Orrin,Orval,Orville,Osbaldo,Osborne,Oscar,Osvaldo,Oswald,Oswaldo,Otho,Otis,Ottis,Otto,Owen,Pablo,Paolo,Paris,Parker,Patrick,Paul,Paxton,Payton,Pedro,Percival,Percy,Perry,Pete,Peter,Peyton,Philip,Pierce,Pierre,Pietro,Porter,Presley,Preston,Price,Prince,Quentin,Quincy,Quinn,Quinten,Quinton,Rafael,Raheem,Rahul,Raleigh,Ralph,Ramiro,Ramon,Randal,Randall,Randi,Randy,Ransom,Raoul,Raphael,Rashad,Rashawn,Rasheed,Raul,Raven,Ray,Raymond,Raymundo,Reagan,Reece,Reed,Reese,Regan,Reggie,Reginald,Reid,Reilly',Reinhold,Remington,Rene,Reuben,Rex,Rey,Reyes,Reymundo,Reynold,Rhett,Rhiannon,Ricardo,Richard,Richie,Richmond,Rick,Rickey,Rickie,Ricky,Rico,Rigoberto,Riley,Robb,Robbie,Robert,Roberto,Robin,Rocio,Rocky,Rod,Roderick,Rodger,Rodolfo,Rodrick,Rodrigo,Roel,Rogelio,Roger,Rogers,Rolando,Rollin,Roman,Ron,Ronaldo,Ronny,Roosevelt,Rory,Rosario,Roscoe,Rosendo,Ross,Rowan,Rowland,Roy,Royal,Royce,Ruben,Rudolph,Rudy,Rupert,Russ,Russel,Russell,Rusty,Ryan,Ryann,Ryder,Rylan,Ryleigh,Ryley,Sage,Saige,Salvador,Salvatore,Sam,Samir,Sammie,Sammy,Samson,Sanford,Santa,Santiago,Santino,Santos,Saul,Savion,Schuyler,Scot,Scottie,Scotty,Seamus,Sean,Sebastian,Sedrick,Selmer,Seth,Shad,Shane,Shaun,Shawn,Shayne,Sheldon,Sheridan,Sherman,Sherwood,Sid,Sidney,Sigmund,Sigrid,Sigurd,Silas,Sim,Simeon,Skye,Skylar,Sofia,Soledad,Solon,Sonny,Spencer,Stan,Stanford,Stanley,Stanton,Stefan,Stephan,Stephen,Stephon,Sterling,Steve,Stevie,Stewart,Stone,Stuart,Sven,Sydney,Sylvan,Sylvester,Tad,Talon,Tanner,Tate,Tatum,Taurean,Tavares,Taylor,Ted,Terence,Terrance,Terrell,Terrence,Terrill,Terry,Tevin,Thad,Thaddeus,Theo,Theodore,Theron,Thomas,Thurman,Tillman,Timmothy,Timmy,Timothy,Tito,Titus,Tobin,Toby,Tod,Tom,Tomas,Tommie,Toney,Toni,Tony,Torey,Torrance,Torrey,Toy,Trace,Tracey,Travis,Travon,Tre,Tremaine,Tremayne,Trent,Trenton,Trever,Trevion,Trevor,Trey',  'Tristian,Tristin,Triston,Troy,Trystan,Turner',Tyler,Tyree,Tyreek,Tyrel,Tyrell,Tyrese,Tyrique,Tyshawn,Tyson,Ubaldo,Ulices,Ulises,Unique,Urban,Uriah,Uriel,Valentin,Van,Vance,Vaughn,Vern,Verner,Vernon,Vicente,Victor,Vidal,Vince,Vincent,Vincenzo,Vinnie,Virgil,Vito,Vladimir,Wade,Waino,Waldo,Walker,Wallace,Walter,Walton,Ward,Warren,Watson,Waylon,Wayne,Webster,Weldon,Wellington,Wendell,Werner,Westley,Weston,Wilber,Wilbert,Wilburn,Wiley,Wilford,Wilfred,Wilfredo,Wilfrid,Wilhelm,Will,Willard,William,Willis,Willy,Wilmer,Wilson,Wilton,Winfield,Winston,Woodrow,Wyatt,Wyman,Xavier,Xzavier,Xander,Zachariah,Zachary,Zachery,Zack,Zackary,Zackery,Zakary,Zander,Zane,Zechariah,Zion".componentsSeparatedByString(",") + "Aaliyah,Abagail,Abbey,Abbie,Abbigail,Abby,Abigail,Abigale,Abigayle,Ada,Adah,Adaline,Addie,Addison,Adela,Adele,Adelia,Adeline,Adell,Adella,Adelle,Aditya,Adriana,Adrianna,Adrienne,Aglae,Agnes,Agustina,Aida,Aileen,Aimee,Aisha,Aiyana,Alaina,Alana,Alanis,Alanna,Alayna,Alba,Alberta,Albertha,Albina,Alda,Aleen,Alejandra,Alena,Alene,Alessandra,Alessia,Aletha,Alexa,Alexandra,Alexandrea,Alexandria,Alexandrine,Alexane,Alexanne,Alfreda,Alia,Alice,Alicia,Alisa,Alisha,Alison,Alivia,Aliya,Aliyah,Aliza,Alize,Allene,Allie,Allison,Ally,Alta,Althea,Alva,Alvena,Alvera,Alverta,Alvina,Alyce,Alycia,Alysa,Alysha,Alyson,Alysson,Amalia,Amanda,Amara,Amaya,Amber,Amelia,Amelie,Amely,America,Amie,Amina,Amira,Amiya,Amy,Amya,Ana,Anabel,Anabelle,Anahi,Anais,Anastasia,Andreane,Andreanne,Angela,Angelica,Angelina,Angeline,Angelita,Angie,Anika,Anissa,Anita,Aniya,Aniyah,Anjali,Anna,Annabel,Annabell,Annabelle,Annalise,Annamae,Annamarie,Anne,Annetta,Annette,Annie,Antoinette,Antonetta,Antonette,Antonia,Antonietta,Antonina,Anya,April,Ara,Araceli,Aracely,Ardella,Ardith,Ariane,Arianna,Arielle,Arlene,Arlie,Arvilla,Aryanna,Asa,Asha,Ashlee,Ashleigh,Ashley,Ashly,Ashlynn,Ashtyn,Asia,Assunta,Astrid,Athena,Aubree,Aubrey,Audie,Audra,Audreanne,Audrey,Augusta,Augustine,Aurelia,Aurelie,Aurore,Autumn,Ava,Avis,Ayana,Ayla,Aylin,Baby,Bailee,Barbara,Beatrice,Beaulah,Bella,Belle,Berenice,Bernadette,Bernadine,Berneice,Bernice,Berniece,Bernita,Bert,Beryl,Bessie,Beth,Bethany,Bethel,Betsy,Bette,Bettie,Betty,Bettye,Beulah,Beverly,Bianka,Billie,Birdie,Blanca,Blanche,Bonita,Bonnie,Brandi,Brandy,Brandyn,Breana,Breanna,Breanne,Brenda,Brenna,Bria,Briana,Brianne,Bridget,Bridgette,Bridie,Brielle,Brigitte,Brionna,Brisa,Britney,Brittany,Brooke,Brooklyn,Bryana,Bulah,Burdette,Burnice,Caitlyn,Caleigh,Cali,Calista,Callie,Camila,Camilla,Camille,Camylle,Candace,Candice,Candida,Cara,Carissa,Carlee,Carley,Carli,Carlie,Carlotta,Carmela,Carmella,Carmen,Carolanne,Carole,Carolina,Caroline,Carolyn,Carolyne,Carrie,Casandra,Cassandra,Cassandre,Cassidy,Cassie,Catalina,Caterina,Catharine,Catherine,Cathrine,Cathryn,Cathy,Cayla,Cecelia,Cecile,Cecilia,Celestine,Celia,Celine,Chanel,Chanelle,Charity,Charlene,Charlotte,Chasity,Chaya,Chelsea,Chelsie,Cheyanne,Cheyenne,Chloe,Christa,Christelle,Christiana,Christina,Christine,Christy,Chyna,Ciara,Cierra,Cindy,Citlalli,Claire,Clara,Clarabelle,Clare,Clarissa,Claudia,Claudie,Claudine,Clementina,Clementine,Clemmie,Cleora,Cleta,Clotilde,Colleen,Concepcion,Connie,Constance,Cora,Coralie,Cordia,Cordie,Corene,Corine,Corrine,Cortney,Courtney,Creola,Cristal,Crystal,Crystel,Cydney,Cynthia,Dahlia,Daija,Daisha,Daisy,Dakota,Damaris,Dana,Dandre,Daniela,Daniella,Danielle,Danika,Dannie,Danyka,Daphne,Daphnee,Daphney,Darby,Dariana,Darlene,Dasia,Dawn,Dayana,Dayna,Deanna,Deborah,Deja,Dejah,Delfina,Delia,Delilah,Della,Delores,Delpha,Delphia,Delphine,Delta,Demetris,Dena,Desiree,Dessie,Destany,Destinee,Destiney,Destini,Destiny,Diana,Dianna,Dina,Dixie,Dolly,Dolores,Domenica,Dominique,Donna,Dora,Dorothea,Dorothy,Dorris,Dortha,Dovie,Drew,Duane,Dulce,Earlene,Earline,Earnestine,Ebba,Ebony,Eda,Eden,Edna,Edwina,Edyth,Edythe,Effie,Eileen,Elaina,Elda,Eldora,Eldridge,Eleanora,Eleanore,Electa,Elena,Elenor,Elenora,Eleonore,Elfrieda,Eliane,Elinor,Elinore,Elisa,Elisabeth,Elise,Elisha,Elissa,Eliza,Elizabeth,Ella,Ellen,Ellie,Elmira,Elna,Elnora,Elody,Eloisa,Eloise,Elouise,Elsa,Else,Elsie,Elta,Elva,Elvera,Elvie,Elyse,Elyssa,Elza,Emelia,Emelie,Emely,Emie,Emilia,Emilie,Emily,Emma,Emmalee,Emmanuelle,Emmie,Emmy,Ena,Enola,Era,Erica,Ericka,Erika,Erna,Ernestina,Ernestine,Eryn,Esmeralda,Esperanza,Esta,Estefania,Estel,Estell,Estella,Estelle,Esther,Estrella,Etha,Ethelyn,Ethyl,Ettie,Eudora,Eugenia,Eula,Eulah,Eulalia,Euna,Eunice,Eva,Evalyn,Evangeline,Eve,Eveline,Evelyn,Everette,Evie,Fabiola,Fae,Fannie,Fanny,Fatima,Fay,Faye,Felicia,Felicita,Felicity,Felipa,Filomena,Fiona,Flavie,Fleta,Flo,Florence,Florida,Florine,Flossie,Frances,Francesca,Francisca,Freda,Frederique,Freeda,Freida,Frida,Frieda,Gabriella,Gabrielle,Gail,Genesis,Genevieve,Genoveva,Georgette,Georgiana,Georgianna,Geraldine,Gerda,Germaine,Gerry,Gertrude,Gia,Gilda,Gina,Giovanna,Gisselle,Gladyce,Gladys,Glenda,Glenna,Gloria,Golda,Grace,Gracie,Graciela,Gregoria,Greta,Gretchen,Guadalupe,Gudrun,Gwen,Gwendolyn,Hailee,Hailie,Halie,Hallie,Hanna,Hannah,Harmony,Hassie,Hattie,Haven,Haylee,Haylie,Heath,Heather,Heaven,Heidi,Helen,Helena,Helene,Helga,Hellen,Heloise,Henriette,Hermina,Herminia,Herta,Hertha,Hettie,Hilda,Hildegard,Hillary,Hilma,Hollie,Holly,Hope,Hortense,Hosea,Hulda,Icie,Ida,Idell,Idella,Ila,Ilene,Iliana,Ima,Imelda,Imogene,Ines,Irma,Isabel,Isabell,Isabella,Isabelle,Isobel,Itzel,Iva,Ivah,Ivory,Ivy,Izabella,Jacinthe,Jackeline,Jackie,Jacklyn,Jacky,Jaclyn,Jacquelyn,Jacynthe,Jada,Jade,Jadyn,Jaida,Jailyn,Jakayla,Jalyn,Jammie,Jana,Janae,Jane,Janelle,Janessa,Janet,Janice,Janie,Janis,Janiya,Jannie,Jany,Jaquelin,Jaqueline,Jaunita,Jayda,Jayne,Jazlyn,Jazmin,Jazmyn,Jazmyne,Jeanette,Jeanie,Jeanne,Jena,Jenifer,Jennie,Jennifer,Jennyfer,Jermaine,Jessica,Jessika,Jessyca,Jewel,Jewell,Joana,Joanie,Joanne,Joannie,Joanny,Jodie,Jody,Joelle,Johanna,Jolie,Jordane,Josefa,Josefina,Josephine,Josiane,Josianne,Josie,Joy,Joyce,Juana,Juanita,Jude,Judy,Julia,Juliana,Julianne,Julie,Juliet,June,Justina,Justine,Kaci,Kacie,Kaela,Kaelyn,Kaia,Kailee,Kailey,Kailyn,Kaitlin,Kaitlyn,Kali,Kallie,Kamille,Kara,Karelle,Karen,Kari,Kariane,Karianne,Karina,Karine,Karlee,Karli,Karlie,Karolann,Kasandra,Kasey,Kassandra,Katarina,Katelin,Katelyn,Katelynn,Katharina,Katherine,Katheryn,Kathleen,Kathlyn,Kathryn,Kathryne,Katlyn,Katlynn,Katrina,Katrine,Kattie,Kavon,Kaya,Kaycee,Kayla,Kaylah,Kaylee,Kayli,Kaylie,Kaylin,Keara,Keely,Keira,Kelli,Kellie,Kelly,Kelsi,Kelsie,Kendra,Kenna,Kenya,Kenyatta,Kiana,Kianna,Kiara,Kiarra,Kiera,Kimberly,Kira,Kirsten,Kirstin,Kitty,Krista,Kristin,Kristina,Kristy,Krystal,Krystel,Krystina,Kyla,Kylee,Kylie,Kyra,Lacey,Lacy,Laila,Laisha,Laney,Larissa,Laura,Lauren,Laurence,Lauretta,Lauriane,Laurianne,Laurie,Laurine,Laury,Lauryn,Lavada,Lavina,Lavinia,Lavonne,Layla,Lea,Leann,Leanna,Leanne,Leatha,Leda,Leila,Leilani,Lela,Lelah,Lelia,Lempi,Lenna,Lenora,Lenore,Leola,Leonie,Leonor,Leonora,Leora,Lera,Leslie,Lesly,Lessie,Leta,Letha,Letitia,Lexi,Lexie,Lia,Liana,Libbie,Libby,Lila,Lilian,Liliana,Liliane,Lilla,Lillian,Lilliana,Lillie,Lilly,Lily,Lilyan,Lina,Linda,Lindsay,Linnea,Linnie,Lisa,Lisette,Litzy,Liza,Lizeth,Lizzie,Lois,Lola,Lolita,Loma,Lonie,Lora,Loraine,Loren,Lorena,Lori,Lorine,Lorna,Lottie,Lou,Loyce,Lucie,Lucienne,Lucile,Lucinda,Lucy,Ludie,Lue,Luella,Luisa,Lulu,Luna,Lupe,Lura,Lurline,Luz,Lyda,Lydia,Lyla,Lynn,Lysanne,Mabel,Mabelle,Mable,Maci,Macie,Macy,Madaline,Madalyn,Maddison,Madeline,Madelyn,Madelynn,Madge,Madie,Madilyn,Madisyn,Madonna,Mae,Maegan,Maeve,Mafalda,Magali,Magdalen,Magdalena,Maggie,Magnolia,Maia,Maida,Maiya,Makayla,Makenzie,Malika,Malinda,Mallie,Malvina,Mandy,Mara,Marcelina,Marcella,Marcelle,Marcia,Margaret,Margarete,Margarett,Margaretta,Margarette,Margarita,Marge,Margie,Margot,Margret,Marguerite,Maria,Mariah,Mariam,Marian,Mariana,Mariane,Marianna,Marianne,Maribel,Marie,Mariela,Marielle,Marietta,Marilie,Marilou,Marilyne,Marina,Marion,Marisa,Marisol,Maritza,Marjolaine,Marjorie,Marjory,Marlee,Marlen,Marlene,Marquise,Marta,Martina,Martine,Mary,Maryam,Maryjane,Maryse,Mathilde,Matilda,Matilde,Mattie,Maud,Maude,Maudie,Maureen,Maurine,Maxie,Maximillia,May,Maya,Maybell,Maybelle,Maye,Maymie,Mayra,Mazie,Mckayla,Meagan,Meaghan,Meda,Megane,Meggie,Meghan,Melba,Melisa,Melissa,Mellie,Melody,Melyna,Melyssa,Mercedes,Meredith,Mertie,Meta,Mia,Micaela,Michaela,Michele,Michelle,Mikayla,Millie,Mina,Minerva,Minnie,Miracle,Mireille,Mireya,Missouri,Misty,Mittie,Modesta,Mollie,Molly,Mona,Monica,Monique,Mossie,Mozell,Mozelle,Muriel,Mya,Myah,Mylene,Myra,Myriam,Myrna,Myrtice,Myrtie,Myrtis,Myrtle,Nadia,Nakia,Name,Nannie,Naomi,Naomie,Natalia,Natalie,Natasha,Nayeli,Nedra,Neha,Nelda,Nella,Nelle,Nellie,Neoma,Nettie,Neva,Nia,Nichole,Nicole,Nicolette,Nikita,Nikki,Nina,Noelia,Noemi,Noemie,Noemy,Nola,Nona,Nora,Norene,Norma,Nova,Novella,Nya,Nyah,Nyasia,Oceane,Ocie,Octavia,Odessa,Odie,Ofelia,Oleta,Olga,Ollie,Oma,Ona,Onie,Opal,Ophelia,Ora,Orie,Orpha,Otha,Otilia,Ottilie,Ova,Ozella,Paige,Palma,Pamela,Pansy,Pascale,Pasquale,Pat,Patience,Patricia,Patsy,Pattie,Paula,Pauline,Pearl,Pearlie,Pearline,Peggie,Penelope,Petra,Phoebe,Phyllis,Pink,Pinkie,Piper,Polly,Precious,Princess,Priscilla,Providenci,Prudence,Queen,Queenie,Rachael,Rachel,Rachelle,Rae,Raegan,Rafaela,Rahsaan,Raina,Ramona,Raphaelle,Raquel,Reanna,Reba,Rebeca,Rebecca,Rebeka,Rebekah,Reina,Renee,Ressie,Reta,Retha,Retta,Reva,Reyna,Rhea,Rhianna,Rhoda,Rita,River,Roberta,Robyn,Roma,Romaine,Rosa,Rosalee,Rosalia,Rosalind,Rosalinda,Rosalyn,Rosamond,Rosanna,Rose,Rosella,Roselyn,Rosemarie,Rosemary,Rosetta,Rosie,Rosina,Roslyn,Rossie,Rowena,Roxane,Roxanne,Rozella,Rubie,Ruby,Rubye,Ruth,Ruthe,Ruthie,Rylee,Sabina,Sabrina,Sabryna,Sadie,Sadye,Sallie,Sally,Salma,Samanta,Samantha,Samara,Sandra,Sandrine,Sandy,Santina,Sarah,Sarai,Sarina,Sasha,Savanah,Savanna,Savannah,Scarlett,Selena,Selina,Serena,Serenity,Shaina,Shakira,Shana,Shanel,Shanelle,Shania,Shanie,Shaniya,Shanna,Shannon,Shanny,Shanon,Shany,Sharon,Shawna,Shaylee,Shayna,Shea,Sheila,Shemar,Shirley,Shyann,Shyanne,Sibyl,Sienna,Sierra,Simone,Sincere,Sister,Skyla,Sonia,Sonya,Sophia,Sophie,Stacey,Stacy,Stefanie,Stella,Stephania,Stephanie,Stephany,Summer,Sunny,Susan,Susana,Susanna,Susie,Suzanne,Syble,Sydnee,Sydni,Sydnie,Sylvia,Tabitha,Talia,Tamara,Tamia,Tania,Tanya,Tara,Taryn,Tatyana,Taya,Teagan,Telly,Teresa,Tess,Tessie,Thalia,Thea,Thelma,Theodora,Theresa,Therese,Theresia,Thora,Tia,Tiana,Tianna,Tiara,Tierra,Tiffany,Tina,Tomasa,Tracy,Tressa,Tressie,Treva,Trinity,Trisha,Trudie,Trycia,Twila,Tyra,Una,Ursula,Vada,Valentina,Valentine,Valerie,Vallie,Vanessa,Veda,Velda,Vella,Velma,Velva,Vena,Verda,Verdie,Vergie,Verla,Verlie,Verna,Vernice,Vernie,Verona,Veronica,Vesta,Vicenta,Vickie,Vicky,Victoria,Vida,Vilma,Vincenza,Viola,Violet,Violette,Virgie,Virginia,Virginie,Vita,Viva,Vivian,Viviane,Vivianne,Vivien,Vivienne,Wanda,Wava,Wendy,Whitney,Wilhelmine,Willa,Willie,Willow,Wilma,Winifred,Winnifred,Winona,Yadira,Yasmeen,Yasmin,Yasmine,Yazmin,Yesenia,Yessenia,Yolanda,Yoshiko,Yvette,Yvonne,Zaria,Zelda,Zella,Zelma,Zena,Zetta,Zita,Zoe,Zoey,Zoie,Zoila,Zola,Zora,Zula".componentsSeparatedByString(",")
    }

    public static func randomFakeGender() -> String {
        return Bool.random() ? "Male" : "Female"
    }

    public static func randomFakeConversation() -> String {
        let convoList = ["You embarrassed me this evening.","You don't think that was just lemonade in your glass, do you?","Do you ever think we should just stop doing this?","Why didn't he come and talk to me himself?","Promise me you'll look after your mother.","If you get me his phone, I might reconsider.","I think the room is bugged.","No! I'm tired of doing what you say.","For some reason, I'm attracted to you."]
        return convoList.randomItem()
    }

    public static func randomFakeTitle() -> String {
        let titleList = ["CEO of Google", "CEO of Facebook", "VP of Marketing @Uber", "Business Developer at IBM", "Jungler @ Fanatic", "B2 Pilot @ USAF", "Student at Stanford", "Student at Harvard", "Mayor of Raccoon City", "CTO @ Umbrella Corporation", "Professor at Pallet Town University"]
        return titleList.randomItem()
    }

    public static func randomFakeTag() -> String {
        let tagList = ["meta", "forum", "troll", "meme", "question", "important", "like4like", "f4f"]
        return tagList.randomItem()
    }

    private static func randomEnglishHonorific() -> String {
        let englishHonorificsList = ["Mr.", "Ms.", "Dr.", "Mrs.", "Mz.", "Mx.", "Prof."]
        return englishHonorificsList.randomItem()
    }

    public static func randomFakeNameAndEnglishHonorific() -> String {
        let englishHonorific = randomEnglishHonorific()
        let name = randomFakeName()
        return englishHonorific + " " + name
    }

    public static func randomFakeCity() -> String {
        let cityPrefixes = ["North", "East", "West", "South", "New", "Lake", "Port"]
        let citySuffixes = ["town", "ton", "land", "ville", "berg", "burgh", "borough", "bury", "view", "port", "mouth", "stad", "furt", "chester", "mouth", "fort", "haven", "side", "shire"]
        return cityPrefixes.randomItem() + citySuffixes.randomItem()
    }

    public static func randomCurrency() -> String {
        let currencyList = ["USD", "EUR", "GBP", "JPY", "AUD", "CAD", "ZAR", "NZD", "INR", "BRP", "CNY", "EGP", "KRW", "MXN", "SAR", "SGD",]

        return currencyList.randomItem()
    }

    public enum GravatarStyle: String {
        case Standard
        case MM
        case Identicon
        case MonsterID
        case Wavatar
        case Retro

        static let allValues = [Standard, MM, Identicon, MonsterID, Wavatar, Retro]
    }

    public static func createGravatar(style: Randoms.GravatarStyle = .Standard, size: Int = 80, completion: ((image: UIImage?, error: NSError?) -> Void)?) {
        var url = "https://secure.gravatar.com/avatar/thisimagewillnotbefound?s=\(size)"
        if style != .Standard {
            url += "&d=\(style.rawValue.lowercaseString)"
        }

        let request = NSURLRequest(URL: NSURL(string: url)!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
        let session = NSURLSession.sharedSession()

        session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    completion?(image: UIImage(data: data!), error: nil)
                } else {
                    completion?(image: nil, error: error)
                }
            }
        }).resume()
    }

    public static func randomGravatar(size: Int = 80, completion: ((image: UIImage?, error: NSError?) -> Void)?) {
        let options = Randoms.GravatarStyle.allValues
        Randoms.createGravatar(options.randomItem(), size: size, completion: completion)
    }
}