global class CreateOrder_WL implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext context) {
        // Order Dummy에서 BatchFlag가 N인 Order 끌고옴
        String query = 'SELECT Id, Name, Order_ID__c, Order_Date__c, Ship_Date__c, Ship_Mode__c, Customer_ID__c, Customer_Name__c, Segment__c, Region__c, RegionalManager__c, CountryRegion__c, City__c, State__c, Postal_Code__c, Product_ID__c, Product_Name__c, Category__c, Sub_Category__c, Discount__c, Sales__c, Profit__c, Quantity__c' ;
        query += ' FROM WL_Dummy_Order__c' ;
        // query += ' WHERE BatchFlag__c = \'N\''; 
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext context, List<WL_Dummy_Order__c> dummyOrderList) {
        Integer orderProductIdx = 0;
        //External Key 선언
        Schema.SObjectField externalIdContact = WL_Contact__c.Fields.Customer_ID__c; 
        Schema.SObjectField externalIdOrder = WL_Orders2__c.Fields.Order_ID__c; 
        Schema.SObjectField externalIdStore = WL_Store__c.Fields.Postal_Code__c;
        Schema.SObjectField externalIdUser = WL_User__c.Fields.ExternalKey__c;
        Schema.SObjectField externalIdProduct = WL_Product2__c.Fields.Product_ID__c; 
        Schema.SObjectField externalIdOrderProduct = WL_OrderProduct2__c.Fields.ExternalKey__c;
    
        // DML 적용할 Map 선언
        Map<String, WL_Orders2__c> orderMap = new Map<String, WL_Orders2__c>(); // Order map
        Map<String, WL_Dummy_Order__c> dummyOrderMap = new Map<String, WL_Dummy_Order__c>(); //dummy map
        Map<String, WL_Contact__c> contactMap = new Map<String, WL_Contact__c>(); // Contact Map
        Map<String, WL_Store__c> storeMap = new Map<String, WL_Store__c>(); // Store Map
        Map<String, WL_User__c> userMap = new Map<String, WL_User__c>(); // User Map
        Map<String, WL_Product2__c> productMap = new Map<String, WL_Product2__c>(); // Product Map
        Map<String, WL_OrderProduct2__c> orderProductMap = new Map<String, WL_OrderProduct2__c>(); // OrderProductMap

        // 더미 오브젝트에 있는 내용 기반으로 각각 오브젝트 만들기
        for(WL_Dummy_Order__c dummyItem : dummyOrderList) {
            // 더미 batch flag 변경 후, Map에 저장
            dummyItem.BatchFlag__c = 'Y';
            dummyOrderMap.put(dummyItem.Id, dummyItem);

            // 1. create Contact obj
            // 더미에 있는 contact Id 확인하기 위해 Contact 생성 후, Map에 저장
            WL_Contact__c contact = new WL_Contact__c();
            contact.Customer_ID__c = dummyItem.Customer_ID__c;
            contact.Customer_Name__c = dummyItem.Customer_Name__c;
            contact.Segment__c = dummyItem.Segment__c;
            contactMap.put(dummyItem.Customer_ID__c, contact);

            // 2. create Store obj
            // 더미에 있는 Region 확인하기 위해 Store 생성 후, Map에 저장
            WL_Store__c store = new WL_Store__c();
            // Postal Code 4글자 -> 5글자 변환
            if (dummyItem.Postal_Code__c == null || dummyItem.Postal_Code__c.length() == 4) {
                dummyItem.Postal_Code__c = '0' + dummyItem.Postal_Code__c;
            }
            store.Postal_Code__c = dummyItem.Postal_Code__c;
            store.Region__c = dummyItem.Region__c;
            store.Country_Region__c = dummyItem.CountryRegion__c;
            store.City__c = dummyItem.City__c;
            store.State__c = dummyItem.State__c;
            storeMap.put(dummyItem.Postal_Code__c, store);

            // 3. create User obj
            // 더미에 있는 User 확인하기 위해 User 생성 후, Map에 저장
            WL_User__c user = new WL_User__c();
            user.Name__c = dummyItem.RegionalManager__c;
            user.WL_Store__r = new WL_Store__c(Postal_Code__c = dummyItem.Postal_Code__c); // MD relationship
            user.ExternalKey__c = dummyItem.RegionalManager__c + dummyItem.Postal_Code__c; //External Key
            userMap.put(user.ExternalKey__c, user); 

            // 4. create Product obj
            // 더미에 있는 Product 확인하기 위해 Product 생성 후, Map에 저장
            WL_Product2__c product = new WL_Product2__c();
            product.Product_ID__c = dummyItem.Product_ID__c;
            product.Product_Name__c = dummyItem.Product_Name__c;
            product.Category__c = dummyItem.Category__c;
            product.Sub_Category__c = dummyItem.Sub_Category__c;
            productMap.put(dummyItem.Product_ID__c, product);

            // 5.create Order obj
            WL_Orders2__c orderItem = new WL_Orders2__c();
            orderItem.Order_ID__c = dummyItem.Order_ID__c;
            orderItem.Ship_Mode__c = dummyItem.Ship_Mode__c;
            
                // Split > Length Checking > String +
            Date orderDateDate = dateParsing(dummyItem.Order_Date__c);
            Date shipDateDate = dateParsing(dummyItem.Ship_Date__c);
     
            orderItem.Order_Date__c = orderDateDate;
            orderItem.Ship_Date__c = shipDateDate;
            orderItem.WL_Store__r = new WL_Store__c(Postal_Code__c = dummyItem.Postal_Code__c);
            orderItem.WL_Contact__r = new WL_Contact__c(Customer_ID__c = dummyItem.Customer_ID__c); 
            orderItem.SalesPerson__c = user.Name__c; 
            orderItem.SalesPrice__c = 0;
            orderItem.IsReturned__c = false;

            orderMap.put(dummyItem.Order_ID__c, orderItem);
        
        // 6. create orderProduct obj
            // 더미에 있는 orderProduct 확인하기 위해 orderProduct 생성 후, Map에 저장
            WL_OrderProduct2__c orderProduct = new WL_OrderProduct2__c();
            orderProduct.WL_Order2__r = new WL_Orders2__c(Order_ID__c = dummyItem.Order_ID__c); // MD relationship 
            orderProduct.WL_Product2__r = new WL_Product2__c(Product_ID__c = dummyItem.Product_ID__c); // LK relationship 
            orderProductIdx += 1;
            // External Key (복합키)
            orderProduct.ExternalKey__c = dummyItem.Order_ID__c + '_' + String.valueOf(orderProductIdx) + '_' + dummyItem.Product_ID__c ;

            orderProduct.Discount__c = Decimal.valueof(dummyItem.Discount__c);
            orderProduct.Sales__c = Decimal.valueof(dummyItem.Sales__c);
            orderProduct.Quantity__c = integer.valueof(dummyItem.Quantity__c);
            orderProduct.Profit__c = Decimal.valueof(dummyItem.Profit__c);

            orderProductMap.put(orderProduct.ExternalKey__c, orderProduct);
        }

        try {
            Database.upsert(contactMap.values(), externalIdContact, true);
            Database.upsert(storeMap.values(), externalIdStore, true);
            Database.upsert(userMap.values(), externalIdUser, true);
            Database.upsert(productMap.values(), externalIdProduct, true);
            Database.upsert(orderMap.values(), externalIdOrder, true);
            Database.upsert(orderProductMap.values(), externalIdOrderProduct, true);
            Database.update(dummyOrderMap.values(), true); // dummy obj
        } catch (Exception e) {
            System.debug(e);
        } 
}

     
    global void finish(Database.BatchableContext context) {
        // ApplyReturn으로 배치체인
        ApplyReturn_WL ret = new ApplyReturn_WL();
        Database.executeBatch(ret, 2000);
    }
    // Date Parsing 작업 (11/8/21 -> 2020-11-03)
    private static Date dateParsing(String dummyDate) {
        List<String> dateSplit = dummyDate.split('/', 3);
        dateSplit[2] = '20' + dateSplit[2];
        String dateSum = dateSplit[2] + '-' + dateSplit[0] + '-' + dateSplit[1];
        Date newDate = Date.valueOf(dateSum); 
        return newDate;
    }
}