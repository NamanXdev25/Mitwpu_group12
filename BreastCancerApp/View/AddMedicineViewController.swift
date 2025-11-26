//
//  AddMedicineViewController.swift
//  BreastCancerApp
//
//  Created by SDC-USER on 26/11/25.
//

import UIKit

class AddMedicineViewController: UIViewController {

    @IBOutlet weak var closeTapped: UIButton!
    
    @IBOutlet weak var saveTapped: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        func closeTapped(_ sender: UIButton) {
                dismiss(animated: true)
            }
        
        func saveTapped(_ sender: UIButton) {
            saveMedicine()
        }
        
        func saveMedicine() {
            print("Saving Medicine...")
            
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
