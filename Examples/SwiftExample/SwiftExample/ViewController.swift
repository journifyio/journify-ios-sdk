//
//  ViewController.swift
//  BasicExample
//
//  Created by Bendnaiba on 2/13/23.
//

#if canImport(UIKit)

import UIKit

#endif
import Journify
import Fakery

class ViewController: UIViewController {
    
    @IBOutlet weak var writeKeyTextField: UITextField!
    @IBOutlet weak var eventView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let outputCapture = OutputPlugin(textView: eventView)
        Journify.shared().add(plugin: outputCapture)
    }

    @IBAction func trackAddProductTapped(_ sender: Any) {
        
        let eventProperties: [String: Any] = [  "cart_id": "skdjsidjsdkdj29j",
                                                "product_id": "507f1f77bcf86cd799439011",
                                                "sku": "G-32",  "category": "Games",
                                                "name": "Monopoly: 3rd Edition",
                                                "brand": "Hasbro",
                                                "variant": "200 pieces",
                                                "price": 18.99,
                                                "quantity": 1,
                                                "coupon": "MAYDEALS",
                                                "position": 3,
                                                "url": "https://www.example.com/product/path",
                                                "image_url": "https://www.example.com/product/path.jpg"]

        Journify.shared().track(name: "Product Added", properties: eventProperties)
    }
    
    @IBAction func trackStartCheckoutTapped(_ sender: Any) {
        let eventProperties: [String: Any] = [  "order_id": "50314b8e9bcf000000000000",
                                                "affiliation": "Google Store",
                                                "value": 30,
                                                "revenue": 25.00,
                                                "shipping": 3,
                                                "tax": 2,
                                                "discount": 2.5,
                                                "coupon": "hasbros",
                                                "currency": "USD"]

        Journify.shared().track(name: "Checkout Started", properties: eventProperties)
    }
    
    @IBAction func trackCompleteOrderTapped(_ sender: Any) {
        let eventProperties: [String: Any] = [  "checkout_id": "fksdjfsdjfisjf9sdfjsd9f",
                                                "order_id": "50314b8e9bcf000000000000",
                                                "affiliation": "Google Store",
                                                "total": 27.50,
                                                "subtotal": 22.50,
                                                "revenue": 25.00,
                                                "shipping": 3,
                                                "tax": 2,
                                                "discount": 2.5,
                                                "coupon": "hasbros",
                                                "currency": "USD"]

        Journify.shared().track(name: "Order Completed", properties: eventProperties)
    }
    
    @IBAction func pageTapped(_ sender: Any) {
        let eventProperties: [String: Any] = ["name": "Page"]

        Journify.shared().screen(title: "Page", properties: eventProperties)
    }
    
    @IBAction func identifyTapped(_ sender: Any) {
        let faker = Faker(locale: "nb-NO")
        let randomUUID = NSUUID().uuidString
        let traits: [String: Any] = ["email": faker.internet.email(),
                      "firstname": faker.name.firstName(),
                      "lastname": faker.name.lastName(),
                      "city": faker.address.city(),
                      "country": faker.address.county(),
                      "state": faker.address.state(),
                      "postal_code": faker.address.postcode(),
                      "ltv": faker.number.randomInt(min: 0, max: 1000)]
        Journify.shared().identify(userId: randomUUID, traits: traits)
    }
    
    @IBAction func flushTapped(_ sender: Any) {
        Journify.shared().flush()
    }
}

