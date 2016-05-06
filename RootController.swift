
import UIKit
import Material
import ChameleonFramework
import Pulsator
import Spring

class RootController: UIViewController {
    
    @IBOutlet weak var pulseView: SpringView!
    
    let pulsator = Pulsator()

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
		prepareView()
        preparePulseView()
        pulsator.start()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(startPulsor), name: UIApplicationWillEnterForegroundNotification, object: nil)
	}

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addCircleBorderToImageView(pulseView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pulseView.layer.layoutIfNeeded()
        pulsator.position = CGPointMake(pulseView.frame.width/2, pulseView.frame.height/2)

        
    }
    
    internal func startPulsor() {
        pulsator.position = CGPointMake(pulseView.frame.width/2, pulseView.frame.height/2)
        pulsator.start()
    }
    
    
    internal func preparePulseView() {
        pulseView.layer.addSublayer(pulsator)
        print(pulseView.bounds.width+10)
        pulsator.radius = pulseView.frame.width-10
    
        pulsator.backgroundColor = MaterialColor.blue.base.CGColor
        pulsator.numPulse = 3
        pulsator.animationDuration = 5
        
        self.addCircleBorderToImageView(pulseView)

    }
	
	/// Prepares view.
	private func prepareView() {
        view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.TopToBottom, withFrame:self.view.bounds, andColors:[UIColor.blackColor(),MaterialColor.amber.base])
	}
    
    func addCircleBorderToImageView(imgView: UIView) {
        //imgView.bounds = CGRectMake(0, 0, dSize, dSize) // centered in container you want to use bounds over frame for this scenario
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = pulseView.bounds.height*1.35
        imgView.layer.borderWidth = 1.0
//        imgView.layer.borderColor = UIColor.redColor().CGColor
    }
    

    
}
