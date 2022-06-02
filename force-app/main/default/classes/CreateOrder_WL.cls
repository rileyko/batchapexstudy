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
    
        // Order Map
        Map<String, WL_Orders2__c> orderMap = new Map<String, WL_Orders2__c>();
        Map<String, WL_Orders2__c> newOrderMap = new Map<String, WL_Orders2__c>();
        Map<String, WL_Dummy_Order__c> dummyOrderMap = new Map<String, WL_Dummy_Order__c>();

        // Contact Map
        Map<String, WL_Contact__c> contactMap = new Map<String, WL_Contact__c>();
        Map<String, WL_Contact__c> newContactMap = new Map<String, WL_Contact__c>();
        
        // Store Map
        Map<String, WL_Store__c> storeMap = new Map<String, WL_Store__c>();
        Map<String, WL_Store__c> newStoreMap = new Map<String, WL_Store__c>();

        // User Map
        Map<String, WL_User__c> userMap = new Map<String, WL_User__c>();
        Map<String, WL_User__c> newUserMap = new Map<String, WL_User__c>();

        // Product Map
        Map<String, WL_Product2__c> productMap = new Map<String, WL_Product2__c>();
        Map<String, WL_Product2__c> newProductMap = new Map<String, WL_Product2__c>();

        // OrderProductMap
        Map<String, WL_OrderProduct2__c> orderProductMap = new Map<String, WL_OrderProduct2__c>();
        Map<String, WL_OrderProduct2__c> neworderProductMap = new Map<String, WL_OrderProduct2__c>();

        // 더미 오브젝트에 있는 내용 기반으로 각각 오브젝트 만들기
        for(WL_Dummy_Order__c dummyItem : dummyOrderList) {
            // 더미 batch flag 변경 후, Map에 저장
            WL_Dummy_Order__c dmOrder = new WL_Dummy_Order__c(Id = dummyItem.Id, BatchFlag__c = 'Y');
            dummyOrderMap.put(dmOrder.Id, dmOrder);

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
            user.WL_Store__r = store; // MD relationship
            user.ExternalKey__c = dummyItem.RegionalManager__c + dummyItem.Postal_Code__c; //External Key
            userMap.put(user.ExternalKey__c, user); //?

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
            // Date Parsing 작업 (11/8/21 -> 2020-11-03)
                // Split > Length Checking > String +
            List<String> orderdateSplit = dummyItem.Order_Date__c.split('/', 3);
            orderdateSplit[2] = '20' + orderdateSplit[2];
            if (orderdateSplit[0].length() != 2) {
                orderdateSplit[0] = '0' + orderdateSplit[0];
            }
            if (orderdateSplit[0].length() != 2) {
                orderdateSplit[1] = '0' + orderdateSplit[1];
            } 
            String orderDateStr = orderdateSplit[0] + '/' + orderdateSplit[1] + '/' + orderdateSplit[2];
            Date orderDateDate = date.parse(orderDateStr);

            List<String> shipdateSplit = dummyItem.Ship_Date__c.split('/', 3);
            shipdateSplit[2] = '20' + shipdateSplit[2];
            if (shipdateSplit[0].length() != 2) {
                shipdateSplit[0] = '0' + shipdateSplit[0];
            }
            if (shipdateSplit[0].length() != 2) {
                shipdateSplit[1] = '0' + shipdateSplit[1];
            } 
            String shipDateStr = shipdateSplit[0] + '/' + shipdateSplit[1] + '/' + shipdateSplit[2];
            Date shipDateDate = date.parse(shipDateStr);
            orderItem.Order_Date__c = orderDateDate;
            orderItem.Ship_Date__c = shipDateDate;
            orderItem.WL_Contact__r = new WL_Contact__c(Customer_ID__c = contact.Customer_ID__c);
            orderItem.WL_Store__c = store.Id;
            orderItem.SalesPerson__c = user.Name__c;
            orderItem.SalesPrice__c = 0;

            orderMap.put(dummyItem.Order_ID__c, orderItem);
        
        // 6. create orderProduct obj
            // 더미에 있는 orderProduct 확인하기 위해 orderProduct 생성 후, Map에 저장
            WL_OrderProduct2__c orderProduct = new WL_OrderProduct2__c();
            orderProduct.WL_Order2__c = orderItem.Id; // MD relationship
            orderProduct.WL_Product2__c = product.Id; // LK relationship
            orderProductIdx += 1;
            // External Key (복합키)
            orderProduct.ExternalKey__c = orderProduct.WL_Order2__c + '_' + String.valueOf(orderProductIdx) + '_' + orderProduct.WL_Product2__c ;

            orderProduct.Discount__c = Decimal.valueof(dummyItem.Discount__c);
            orderProduct.Sales__c = Decimal.valueof(dummyItem.Sales__c);
            orderProduct.Quantity__c = integer.valueof(dummyItem.Quantity__c);
            orderProduct.Profit__c = Decimal.valueof(dummyItem.Profit__c);

            orderProductMap.put(orderProduct.ExternalKey__c, orderProduct);
        }
        // Org에 존재하는 레코드 판별 - Contact
        List<WL_Contact__c> contactList = [SELECT Id, Customer_ID__c, Customer_Name__c, Segment__c FROM WL_Contact__c WHERE Customer_ID__c in : contactMap.keySet()];
        Map<String, WL_Contact__c> orgContactMap = new Map<String, WL_Contact__c>();
        for(WL_Contact__c orgContactItem : contactList){
            orgContactMap.put(orgContactItem.Customer_ID__c, orgContactItem);
        }
        // Dummy(contactMap)와 Org(orgContactMap) 비교 - Contact
        for(String contactIdItem : contactMap.keySet()){
            if(orgContactMap.containsKey(contactIdItem)) {
                if((orgContactMap.get(contactIdItem).Customer_Name__c == contactMap.get(contactIdItem).Customer_Name__c) 
                && orgContactMap.get(contactIdItem).Segment__c == contactMap.get(contactIdItem).Segment__c) {
                    continue;
                }else {
                    WL_Contact__c cont = contactMap.get(contactIdItem);
                    newContactMap.put(contactIdItem, cont);
                }
            }else {
                WL_Contact__c cont = contactMap.get(contactIdItem);
                newContactMap.put(contactIdItem, cont);
            }
        }

        // Org에 존재하는 레코드 판별 - Store
        List<WL_Store__c> storeList = [SELECT City__c, Country_Region__c, Postal_Code__c, Region__c, State__c FROM WL_Store__c WHERE Postal_Code__c in : contactMap.keySet()];
        Map<String, WL_Store__c> orgStoreMap = new Map<String, WL_Store__c>();
        for(WL_Store__c orgStoreItem : storeList){
            orgStoreMap.put(orgStoreItem.Postal_Code__c, orgStoreItem);
        }
        // Dummy(storeMap)와 Org(orgStoreMap) 비교 - Store
        for(String storeIdItem : storeMap.keySet()){
            if(orgStoreMap.containsKey(storeIdItem)) {
                if((orgStoreMap.get(storeIdItem).City__c == storeMap.get(storeIdItem).City__c) 
                && orgStoreMap.get(storeIdItem).Country_Region__c == storeMap.get(storeIdItem).Country_Region__c
                && orgStoreMap.get(storeIdItem).Region__c == storeMap.get(storeIdItem).Region__c
                && orgStoreMap.get(storeIdItem).State__c == storeMap.get(storeIdItem).State__c) {
                    continue;
                }else {
                    WL_Store__c st = storeMap.get(storeIdItem);
                    newStoreMap.put(storeIdItem, st);
                }
            }else {
                WL_Store__c st = storeMap.get(storeIdItem);
                newStoreMap.put(storeIdItem, st);
            }
        }
        // Org에 존재하는 레코드 판별 - User
        List<WL_User__c> userList = [SELECT Name__c, WL_Store__c, ExternalKey__c FROM WL_User__c WHERE ExternalKey__c in : userMap.keySet()];
        Map<String, WL_User__c> orgUserMap = new Map<String, WL_User__c>();
        for(WL_User__c orgUserItem : userList){
            orgUserMap.put(orgUserItem.ExternalKey__c, orgUserItem);
        }

        // Dummy(userMap)와 Org(orgUserMap) 비교 - User
        for(String userIdItem : userMap.keySet()){
            if(orgUserMap.containsKey(userIdItem)) {
                if(orgUserMap.get(userIdItem).WL_Store__c == userMap.get(userIdItem).WL_Store__c 
                && orgUserMap.get(userIdItem).Name__c == userMap.get(userIdItem).Name__c) {
                    continue;
                }else {
                    WL_User__c userItem = userMap.get(userIdItem);
                    newUserMap.put(userIdItem, userItem);
                    System.debug(newUserMap);
                }
            }else {
                WL_User__c userItem = userMap.get(userIdItem);
                newUserMap.put(userIdItem, userItem);
            }
        }
        // Org에 존재하는 레코드 판별 - Product
        List<WL_Product2__c> productList = [SELECT Product_ID__c, Product_Name__c,Category__c, Sub_Category__c  FROM WL_Product2__c WHERE Product_ID__c in : productMap.keySet()];
        Map<String, WL_Product2__c> orgProdMap = new Map<String, WL_Product2__c>();
        for(WL_Product2__c orgProdItem : productList){
            orgProdMap.put(orgProdItem.Product_ID__c, orgProdItem);
        }

        // Dummy(productMap)와 Org(orgProdMap) 비교 - Product
        for(String prodIdItem : productMap.keySet()){
            if(orgProdMap.containsKey(prodIdItem)) {
                if(orgProdMap.get(prodIdItem).Product_Name__c == productMap.get(prodIdItem).Product_Name__c 
                && orgProdMap.get(prodIdItem).Category__c == productMap.get(prodIdItem).Category__c
                && orgProdMap.get(prodIdItem).Sub_Category__c == productMap.get(prodIdItem).Sub_Category__c) {
                    continue;
                }else {
                    WL_Product2__c prod = productMap.get(prodIdItem);
                    newProductMap.put(prodIdItem, prod);
                }
            }else {
                WL_Product2__c prod = productMap.get(prodIdItem);
                newProductMap.put(prodIdItem, prod);
            }
        }

        // Org에 존재하는 레코드 판별 - Order
        List<WL_Orders2__c> orderList = [SELECT Order_ID__c, Order_Date__c, SalesPerson__c, SalesPrice__c, Ship_Date__c, Ship_Mode__c, WL_Contact__c, WL_Store__c  FROM WL_Orders2__c WHERE Order_ID__c in : orderMap.keySet()];
        Map<String, WL_Orders2__c> orgOrderMap = new Map<String, WL_Orders2__c>();
        for(WL_Orders2__c orgOrderItem : orderList){
            orgOrderMap.put(orgOrderItem.Order_ID__c, orgOrderItem);
        }
        // Dummy(orderMap)와 Org(orgOrderMap) 비교 - Order
        for(String orderIdItem : orderMap.keySet()){
            if(orgOrderMap.containsKey(orderIdItem)) {
                if(orgOrderMap.get(orderIdItem).Order_Date__c == orderMap.get(orderIdItem).Order_Date__c 
                && orgOrderMap.get(orderIdItem).SalesPerson__c == orderMap.get(orderIdItem).SalesPerson__c
                && orgOrderMap.get(orderIdItem).SalesPrice__c == orderMap.get(orderIdItem).SalesPrice__c
                && orgOrderMap.get(orderIdItem).Ship_Date__c == orderMap.get(orderIdItem).Ship_Date__c
                && orgOrderMap.get(orderIdItem).Ship_Mode__c == orderMap.get(orderIdItem).Ship_Mode__c
                && orgOrderMap.get(orderIdItem).WL_Contact__c == orderMap.get(orderIdItem).WL_Contact__c
                && orgOrderMap.get(orderIdItem).WL_Store__c == orderMap.get(orderIdItem).WL_Store__c
                ) {
                    continue;
                }
            }else {
                WL_Orders2__c ord = orderMap.get(orderIdItem);
                newOrderMap.put(orderIdItem, ord);
            }
        }
        // Org에 존재하는 레코드 판별 - OrderProduct
        List<WL_OrderProduct2__c> orderProductList = [SELECT ExternalKey__c, OrderProductNo__c, Profit__c, Quantity__c, Discount__c, Sales__c, WL_Order2__c, WL_Product2__c  FROM WL_OrderProduct2__c WHERE ExternalKey__c in : orderProductMap.keySet()];
        Map<String, WL_OrderProduct2__c> orgOrderProductMap = new Map<String, WL_OrderProduct2__c>();
        for(WL_OrderProduct2__c orgProdOrderItem : orderProductList){
            orgOrderProductMap.put(orgProdOrderItem.ExternalKey__c, orgProdOrderItem);
        }
        // Dummy(orderProductMap)와 Org(orgOrderProductMap) 비교 - OrderProduct
        // 가격이 바뀌고 나머지 정보가 같다면 새로운 정션으로 봐야함?
        for(String orderproductIdItem : orderProductMap.keySet()){
            if(orgOrderProductMap.containsKey(orderproductIdItem)) {
                if(orgOrderProductMap.get(orderproductIdItem).Profit__c == orderProductMap.get(orderproductIdItem).Profit__c 
                && orgOrderProductMap.get(orderproductIdItem).Quantity__c == orderProductMap.get(orderproductIdItem).Quantity__c
                && orgOrderProductMap.get(orderproductIdItem).Sales__c == orderProductMap.get(orderproductIdItem).Sales__c
                && orgOrderProductMap.get(orderproductIdItem).Discount__c == orderProductMap.get(orderproductIdItem).Discount__c
                && orgOrderProductMap.get(orderproductIdItem).WL_Order2__c == orderProductMap.get(orderproductIdItem).WL_Order2__c
                && orgOrderProductMap.get(orderproductIdItem).WL_Product2__c == orderProductMap.get(orderproductIdItem).WL_Product2__c
                ) {
                    continue;
                }
            }
        else {
            WL_OrderProduct2__c op = orderProductMap.get(orderproductIdItem);
            newOrderProductMap.put(orderproductIdItem, op);
        }
    }

        try {
            // Update 과정 (Order -> Return Dummy)
            Database.upsert(newContactMap.values(), externalIdContact, true);
            Database.upsert(newStoreMap.values(), externalIdStore, true);
            Database.upsert(newProductMap.values(), externalIdProduct, true);
            Database.upsert(newOrderMap.values(), externalIdOrder, true);
            // Database.upsert(newUserMap.values(), externalIdUser, true);
            // Database.upsert(newOrderProductMap.values(), externalIdOrderProduct, true);
            Database.update(dummyOrderMap.values(), true); // dummy obj
        } catch (Exception e) {
            System.debug(e);
        } 
}

     
    global void finish(Database.BatchableContext context) {
        // ApplyReturn으로 배치체인
        ApplyReturn_WL ret = new ApplyReturn_WL();
        Database.executeBatch(ret, 200);
    }
}