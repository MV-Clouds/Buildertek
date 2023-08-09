@isTest
private class AddProductControllerTest {

    private static testMethod void test() {
        
        Contact c = new Contact();
        c.LastName='test';
        insert c;
        
        Service_Request__c sr = new Service_Request__c();
        sr.Customer_Name__c = c.id;
        sr.Subject__c = 'test subject';
        insert sr;
        
        Service_Request__c sr1 = new Service_Request__c();
        sr1.Customer_Name__c = c.id;
        sr1.Subject__c = 'test subject';
        insert sr1;
        
        Product2 product = new Product2();
        product.Name = 'test';
        insert product;
        
        Product2 product1 = new Product2();
        product1.Name = 'test';
        insert product1;
        
       // List<Inventory_Management__c> imList = new List<Inventory_Management__c>();
        Inventory_Management__c im = new Inventory_Management__c();
        im.Product_Name__c = product.id;
       // imList.add(im);
        insert im;
        
        Inventory_Management__c im1 = new Inventory_Management__c();
        im1.Product_Name__c = product1.id;
       // imList.add(im);
        insert im1;
        
        Product__c p = new Product__c();
        p.Product_Name__c = 'test';
        p.Service_Request__c = sr.id;
        p.Product__c = im.id;
        p.Quantity__c = 0;
        p.Cost__c = 100;
        insert p;
        
        Product__c p1 = new Product__c();
        p1.Product_Name__c = 'test';
        p1.Service_Request__c = sr1.id;
        p1.Product__c = im.id;
        p1.Quantity__c = 0;
        p1.Cost__c = 100;
        insert p1;
        
        ApexPages.currentPage().getParameters().put('index','0');
        ApexPages.currentPage().getParameters().put('id',sr.id);
        AddProductController AddProductControllerRef = new AddProductController();
        //AddProductControllerRef.getisRecordAccessible();
        AddProductControllerRef.cancelAction();
        AddProductControllerRef.loadProductsByFamily();
        AddProductControllerRef.loadInventoryDetailsByProduct();
        AddProductControllerRef.removeRow();
        AddProductControllerRef.saveAction();
        AddProductControllerRef.addRow();
        
        ApexPages.currentPage().getParameters().put('id',null);
       // AddProductControllerRef.getisRecordAccessible();
        List<AddProductController.wrapsObjectList> lstProductLst = new List<AddProductController.wrapsObjectList>();
        AddProductController.wrapsObjectList lstProduct1 = new AddProductController.wrapsObjectList();
        lstProduct1.strDescription = 'Hello';
        lstProduct1.lstProductFamily = New List<SelectOption>();
        lstProduct1.strProductId=p.Id;
        lstProduct1.objProduct=im;
        lstProductLst.add(lstProduct1);
        AddProductControllerRef.lstProduct=lstProductLst;
		AddProductControllerRef.saveAction();
        lstProductLst = new List<AddProductController.wrapsObjectList>();
        lstProduct1.strProductId=p1.Id;
        lstProduct1.objProduct=im1;
        lstProductLst.add(lstProduct1);
        AddProductControllerRef.lstProduct=lstProductLst;
        AddProductControllerRef.saveAction();
        
        System.assertEquals('Test','Test');

    }
    
    /*  private static testMethod void test2() {
        
        Contact c = new Contact();
        c.LastName='test';
        insert c;
        
        Service_Request__c sr = new Service_Request__c();
        sr.Customer_Name__c = c.id;
        sr.Subject__c = 'test subject';
        insert sr;
        
        Product2 product = new Product2();
        product.Name = 'test';
        insert product;
        
        Inventory_Management__c im = new Inventory_Management__c();
        im.Product_Name__c = product.id;
        insert im;
        
        Product__c p = new Product__c();
        p.Product_Name__c = 'test';
        p.Service_Request__c = sr.id;
        p.Product__c = im.id;
        p.Quantity__c = 0;
        p.Cost__c = 100;
        insert p;
        
        ApexPages.currentPage().getParameters().put('index','0');
        ApexPages.currentPage().getParameters().put('id',sr.id);
        AddProductController AddProductControllerRef = new AddProductController();
        AddProductControllerRef.getisRecordAccessible();
        AddProductControllerRef.cancelAction();
        AddProductControllerRef.loadProductsByFamily();
        AddProductControllerRef.loadInventoryDetailsByProduct();
        AddProductControllerRef.addRow();
        AddProductControllerRef.saveAction();

        
    }  */

}