import UIKit

extension UIColor {

    class func speciesColor(forIndex index: Int, isLight: Bool) -> UIColor {
		
		switch index {
		case 0:
			if isLight {
				return sunglow()
			} else {
                return sun()
			}
        case 1:
            if isLight {
                return shuttleGray()
            } else {
                return rhino()
            }
        case 2:
            if isLight {
                return mantis()
            } else {
                return asparagus()
            }
        case 3:
            if isLight {
                return #colorLiteral(red: 0.7949928548, green: 0.6469059504, blue: 0.6469059504, alpha: 1)
            } else {
                return #colorLiteral(red: 0.5009930134, green: 0.4058532119, blue: 0.4035398364, alpha: 1)
            }
        case 4:
            if isLight {
                return #colorLiteral(red: 0.9682237886, green: 0.6859217059, blue: 0.3609863759, alpha: 1)
            } else {
                return #colorLiteral(red: 0.7618371248, green: 0.5363039374, blue: 0.2718488574, alpha: 1)
            }
        case 5:
            if isLight {
                return #colorLiteral(red: 0.2032909253, green: 0.5485599758, blue: 0.1530638014, alpha: 1)
            } else {
                return #colorLiteral(red: 0.1193666235, green: 0.324714005, blue: 0.08855458349, alpha: 1)
            }
        case 6:
            if isLight {
                return purpleMountainsMajesty()
            } else {
                return mulledWine()
            }
        case 7:
            if isLight {
                return #colorLiteral(red: 0.4824384836, green: 0.8372815179, blue: 0.9991987436, alpha: 1)
            } else {
                return #colorLiteral(red: 0.4220160246, green: 0.7173771858, blue: 0.8544768095, alpha: 1)
            }
        case 8:
            if isLight {
                return spanishGreen()
            } else {
                return limedAsh()
            }
        case 9:
            if isLight {
                return #colorLiteral(red: 0.8498594648, green: 0.9134838887, blue: 0.4711037368, alpha: 1)
            } else {
                return #colorLiteral(red: 0.693793416, green: 0.7444642186, blue: 0.3813612163, alpha: 1)
            }
        case 10:
            if isLight {
                return #colorLiteral(red: 0.8614662383, green: 0.7807986708, blue: 0.2414655356, alpha: 1)
            } else {
                return #colorLiteral(red: 0.7140598297, green: 0.6493981481, blue: 0.1938434243, alpha: 1)
            }
        default:
            print("you know nothing")
		}
	
        return UIColor.white()
	}

    /**
     name: Limed Ash
     red: 0.4509803922
     green: 0.5098039216
     blue: 0.4078431373
     alpha: 1.0000000000
     hex: #738268
     **/
    
    public class func limedAsh() -> UIColor {
        return UIColor(red: 0.4509803922, green: 0.5098039216, blue: 0.4078431373, alpha: 1.0000000000);
    }
    
	/**
	 name: Asparagus
	 red: 0.4666666667
	 green: 0.6745098039
	 blue: 0.3058823529
	 alpha: 1.0000000000
	 hex: #77AC4E
	 **/

	public class func asparagus() -> UIColor {
		return UIColor(red: 0.4666666667, green: 0.6745098039, blue: 0.3058823529, alpha: 1.0000000000);
	}

	/**
	 name: Mantis
	 red: 0.5843137255
	 green: 0.7490196078
	 blue: 0.3058823529
	 alpha: 1.0000000000
	 hex: #95BF4E
	 **/

	public class func mantis() -> UIColor {
		return UIColor(red: 0.5843137255, green: 0.7490196078, blue: 0.3058823529, alpha: 1.0000000000);
	}

	/**
	 name: Viking
	 red: 0.3137254902
	 green: 0.7137254902
	 blue: 0.7843137255
	 alpha: 1.0000000000
	 hex: #50B6C8
	 **/

	public class func viking() -> UIColor {
		return UIColor(red: 0.3137254902, green: 0.7137254902, blue: 0.7843137255, alpha: 1.0000000000);
	}

	/**
	 name: Chathams Blue
	 red: 0.0823529412
	 green: 0.3098039216
	 blue: 0.4470588235
	 alpha: 1.0000000000
	 hex: #154F72
	 **/

	public class func chathamsBlue() -> UIColor {
		return UIColor(red: 0.0823529412, green: 0.3098039216, blue: 0.4470588235, alpha: 1.0000000000);
	}

	/**
	 name: Finch
	 red: 0.4666666667
	 green: 0.4980392157
	 blue: 0.3529411765
	 alpha: 1.0000000000
	 hex: #777F5A
	 **/

	public class func finch() -> UIColor {
		return UIColor(red: 0.4666666667, green: 0.4980392157, blue: 0.3529411765, alpha: 1.0000000000);
	}

	/**
	 name: Spanish Green
	 red: 0.5411764706
	 green: 0.6117647059
	 blue: 0.4901960784
	 alpha: 1.0000000000
	 hex: #8A9C7D
	 **/

	public class func spanishGreen() -> UIColor {
		return UIColor(red: 0.5411764706, green: 0.6117647059, blue: 0.4901960784, alpha: 1.0000000000);
	}

	/**
	 name: Lightning Yellow
	 red: 0.9764705882
	 green: 0.6627450980
	 blue: 0.1960784314
	 alpha: 1.0000000000
	 hex: #F9A932
	 **/

	public class func lightningYellow() -> UIColor {
		return UIColor(red: 0.9764705882, green: 0.6627450980, blue: 0.1960784314, alpha: 1.0000000000);
	}

	/**
	 name: Supernova
	 red: 0.9843137255
	 green: 0.7137254902
	 blue: 0.1960784314
	 alpha: 1.0000000000
	 hex: #FBB632
	 **/

	public class func supernova() -> UIColor {
		return UIColor(red: 0.9843137255, green: 0.7137254902, blue: 0.1960784314, alpha: 1.0000000000);
	}

	/**
	 name: Mulled Wine
	 red: 0.3254901961
	 green: 0.2745098039
	 blue: 0.4352941176
	 alpha: 1.0000000000
	 hex: #53466F
	 **/

	public class func mulledWine() -> UIColor {
		return UIColor(red: 0.3254901961, green: 0.2745098039, blue: 0.4352941176, alpha: 1.0000000000);
	}

	/**
	 name: Purple Mountain's Majesty
	 red: 0.5372549020
	 green: 0.4705882353
	 blue: 0.7058823529
	 alpha: 1.0000000000
	 hex: #8978B4
	 **/

	public class func purpleMountainsMajesty() -> UIColor {
		return UIColor(red: 0.5372549020, green: 0.4705882353, blue: 0.7058823529, alpha: 1.0000000000);
	}

	/**
	 name: Apple
	 red: 0.4274509804
	 green: 0.6235294118
	 blue: 0.2784313725
	 alpha: 1.0000000000
	 hex: #6D9F47
	 **/

	public class func apple() -> UIColor {
		return UIColor(red: 0.4274509804, green: 0.6235294118, blue: 0.2784313725, alpha: 1.0000000000);
	}

	/**
	 name: Wild Willow
	 red: 0.6627450980
	 green: 0.8117647059
	 blue: 0.4117647059
	 alpha: 1.0000000000
	 hex: #A9CF69
	 **/

	public class func wildWillow() -> UIColor {
		return UIColor(red: 0.6627450980, green: 0.8117647059, blue: 0.4117647059, alpha: 1.0000000000);
	}

	/**
	 name: Daisy Bush
	 red: 0.3450980392
	 green: 0.2313725490
	 blue: 0.5411764706
	 alpha: 1.0000000000
	 hex: #583B8A
	 **/

	public class func daisyBush() -> UIColor {
		return UIColor(red: 0.3450980392, green: 0.2313725490, blue: 0.5411764706, alpha: 1.0000000000);
	}

	/**
	 name: Lily
	 red: 0.7568627451
	 green: 0.5686274510
	 blue: 0.7333333333
	 alpha: 1.0000000000
	 hex: #C191BB
	 **/

	public class func lily() -> UIColor {
		return UIColor(red: 0.7568627451, green: 0.5686274510, blue: 0.7333333333, alpha: 1.0000000000);
	}

	/**
	 name: Palm Leaf
	 red: 0.1882352941
	 green: 0.3019607843
	 blue: 0.1490196078
	 alpha: 1.0000000000
	 hex: #304D26
	 **/

	public class func palmLeaf() -> UIColor {
		return UIColor(red: 0.1882352941, green: 0.3019607843, blue: 0.1490196078, alpha: 1.0000000000);
	}

	/**
	 name: Green House
	 red: 0.2588235294
	 green: 0.4431372549
	 blue: 0.2274509804
	 alpha: 1.0000000000
	 hex: #42713A
	 **/

	public class func greenHouse() -> UIColor {
		return UIColor(red: 0.2588235294, green: 0.4431372549, blue: 0.2274509804, alpha: 1.0000000000);
	}

	/**
	 name: Rhino
	 red: 0.2392156863
	 green: 0.2745098039
	 blue: 0.3137254902
	 alpha: 1.0000000000
	 hex: #3D4650
	 **/

	public class func rhino() -> UIColor {
		return UIColor(red: 0.2392156863, green: 0.2745098039, blue: 0.3137254902, alpha: 1.0000000000);
	}

	/**
	 name: Shuttle Gray
	 red: 0.3568627451
	 green: 0.3882352941
	 blue: 0.4470588235
	 alpha: 1.0000000000
	 hex: #5B6372
	 **/

	public class func shuttleGray() -> UIColor {
		return UIColor(red: 0.3568627451, green: 0.3882352941, blue: 0.4470588235, alpha: 1.0000000000);
	}

	/**
	 name: Sun
	 red: 0.9607843137
	 green: 0.5568627451
	 blue: 0.1882352941
	 alpha: 1.0000000000
	 hex: #F58E30
	 **/

	public class func sun() -> UIColor {
		return UIColor(red: 0.9607843137, green: 0.5568627451, blue: 0.1882352941, alpha: 1.0000000000);
	}

	/**
	 name: Sunglow
	 red: 0.9921568627
	 green: 0.7647058824
	 blue: 0.2117647059
	 alpha: 1.0000000000
	 hex: #FDC336
	 **/

	public class func sunglow() -> UIColor {
		return UIColor(red: 0.9921568627, green: 0.7647058824, blue: 0.2117647059, alpha: 1.0000000000);
	}

	/**
	 name: Salem
	 red: 0.1137254902
	 green: 0.5725490196
	 blue: 0.2588235294
	 alpha: 1.0000000000
	 hex: #1D9242
	 **/

	public class func salem() -> UIColor {
		return UIColor(red: 0.1137254902, green: 0.5725490196, blue: 0.2588235294, alpha: 1.0000000000);
	}

	/**
	 name: Chateau Green
	 red: 0.1607843137
	 green: 0.6901960784
	 blue: 0.3137254902
	 alpha: 1.0000000000
	 hex: #29B050
	 **/

	public class func chateauGreen() -> UIColor {
		return UIColor(red: 0.1607843137, green: 0.6901960784, blue: 0.3137254902, alpha: 1.0000000000);
	}

    
    
}
