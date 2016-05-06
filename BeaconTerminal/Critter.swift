
import Foundation
import RealmSwift

class Critter : Object{
	
	dynamic var imgUrl  = ""
	dynamic var color = ""
    dynamic var name  = ""
    dynamic var index = 0
    dynamic var last_modified = NSDate()

}