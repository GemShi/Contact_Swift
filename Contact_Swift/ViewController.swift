//
//  ViewController.swift
//  Contact_Swift
//
//  Created by GemShi on 2017/8/23.
//  Copyright © 2017年 GemShi. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class ViewController: UIViewController ,CNContactPickerDelegate ,UITableViewDelegate ,UITableViewDataSource {

    let PHONEKEY = "phoneNumbers"
    var dataArray:Array<Any> = []
    var tableView = UITableView()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initData()
        createLayout()
    }

    func initData() -> Void {
        registAuthorize()
    }
    
    func registAuthorize() -> Void {
        let authorizeState = CNContactStore.authorizationStatus(for: .contacts)
        if authorizeState == .notDetermined {
            //用户还未决定授权
            let contactStore = CNContactStore.init()
            contactStore.requestAccess(for: .contacts, completionHandler: { (granted: Bool, error: Error?) in
                if granted {
                    print("授权成功")
                    self.createCustomContactData()
                }else{
                    print("授权失败")
                }
            })
            
        }else if authorizeState == .authorized {
            //用户确认授权
            createCustomContactData()
        }else{
            //用户拒绝或者有程序阻止了通讯录调起
        }
    }
    
    func createCustomContactData() -> Void {
        let contactStore = CNContactStore.init()
        let keys = [CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest.init(keysToFetch: keys as [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request, usingBlock: {(contact : CNContact, stop : UnsafeMutablePointer<ObjCBool>) -> Void in
                
                self.dataArray.append(contact)
                
                //1.获取姓名
                let lastName = contact.familyName
                let firstName = contact.givenName
                print("姓名 : \(lastName)\(firstName)")
                
                //2.获取电话号码
                let phoneNumbers = contact.phoneNumbers
                for phoneNumber in phoneNumbers {
                    print(phoneNumber.label ?? "")
                    print(phoneNumber.value.stringValue)
                }
                
                //3.回到主线程刷新UI
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            })
        } catch  {
            print(error)
        }
        
    }
    
    func createLayout() -> Void {
        tableView = UITableView.init(frame: self.view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        self.view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle
            , reuseIdentifier: "contactCell");
        if dataArray.isEmpty == false {
            print(self.dataArray)
            
            let contact = dataArray[indexPath.row]
            let labelValue = (contact as AnyObject).phoneNumbers.first
            cell.textLabel?.text = labelValue?.value.stringValue
            cell.detailTextLabel?.text = (contact as AnyObject).familyName + (contact as AnyObject).givenName
        }
        return cell
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let cpvc = CNContactPickerViewController()
//        cpvc.delegate = self
//        self.present(cpvc, animated: true, completion: nil)
//    }
//    
//    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
//        print(contactProperty.contact.familyName + contactProperty.contact.givenName)
//        if contactProperty.key == PHONEKEY {
//            for labelVale in contactProperty.contact.phoneNumbers {
//                if contactProperty.identifier == labelVale.identifier {
//                    let phoneStr = labelVale.value.stringValue
//                    print(phoneStr)
//                }
//            }
//        }
//    }


}

