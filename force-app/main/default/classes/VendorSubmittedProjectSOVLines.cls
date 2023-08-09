public without sharing class VendorSubmittedProjectSOVLines {
    //Retrieve ProjectTakeOff
    @AuraEnabled
    public static ProjectRecordDetails getProjectDetails(String recordId){
        try{
            if (String.isNotBlank(recordId)){
                ProjectRecordDetails projectRec = new ProjectRecordDetails();
                projectRec.projectRec = [Select Id, Name, buildertek__Stage__c, buildertek__Type__c
                                                                                   FROM buildertek__Project__c
                                                                                   WHERE Id = :recordId];
                return projectRec;
            }
        } catch (Exception e){
            System.debug('Error Message::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    //Get All Products, TakeOffLines records and Selection Sheet TakeOff Lines
    @AuraEnabled
    public static ProductClass getAllProductsAndTakeOffLines(String recordId, Integer productPageNumber, Integer productPageSize, Integer pageNumber, Integer pageSize, Integer SSTLPageNumber, Integer SSTLPageSize){
       // try{
            return searchQueryResult2(recordId, productPageNumber, productPageSize, pageNumber, pageSize, SSTLPageNumber, SSTLPageSize, '', '', '', '', '', '', '', '', '', '', '','');
       // } catch (Exception e){
        //    System.debug('Error Message::' + e.getMessage());
       //     System.debug('Error Line::' + e.getLineNumber());
     //       throw new AuraHandledException(e.getMessage());
      //  }
    }

    //Get All Selected Products, TakeOffLines records and Selection Sheet TakeOff Lines
    @AuraEnabled
    public static ProductClass getAllProductsAndSelectedTakeOffLines(String recordId, Integer productPageNumber, Integer productPageSize, Integer pageNumber, Integer pageSize, Integer SSTLPageNumber, Integer SSTLPageSize, String filteredTakeOffLines){
     //   try{
            ProductClass productClassWrapper = new ProductClass();
            //Base Query for Product2
            String query = '';
            String filter = '';

            Integer offset = (pageNumber - 1) * pageSize;//For SSTL
            Integer SSTLOffset = (SSTLPageNumber - 1) * SSTLPageSize;//For SSTL
            buildertek__Project_Selection_Sheet_Takeoff__c projectSelectionSheetTakeOff = [Select Id, Name, buildertek__Takeoff__c, buildertek__Project__c, buildertek__Project__r.Name, buildertek__Project__r.buildertek__Project_Tiers__c, buildertek__Project__r.buildertek__Plan_Type__c
                                                                                           FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                                           WHERE Id = :recordId
                                                                                           LIMIT 1];
            system.debug('projectSelectionSheetTakeOff:::::' + projectSelectionSheetTakeOff.buildertek__Takeoff__c);
            string takeOffId = projectSelectionSheetTakeOff.buildertek__Takeoff__c;
            system.debug('takeOffId:::::' + takeOffId);
            List<Product2> productList = (List<Product2>)JSON.deserialize(filteredTakeOffLines, List<Product2>.class);
            //Take Off Lines
            query = 'Select Id,Name,buildertek__Categories__c, buildertek__Categories__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Location__c, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Quantity__c FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c =:takeOffId ';
            filter = '';
            //Filter query based on Product2.
            for (Product2 product : productList){
                filter += product.buildertek__Trade_Type__c == null ? ' OR ( buildertek__Trade_Type__c = null' : ' OR ( buildertek__Trade_Type__c =\'' + product.buildertek__Trade_Type__c + '\'';
                filter += product.buildertek__Product_Type__c == null ? ' AND buildertek__Product_Type__c = null' : ' AND buildertek__Product_Type__c =\'' + product.buildertek__Product_Type__c + '\'';
                filter += product.buildertek__Category__c == null ? ' AND buildertek__Categories__c = null' : ' AND buildertek__Categories__c =\'' + product.buildertek__Category__c + '\'';
                filter += ' ) ';
            }
            query += filter;
            //query = query.replace(' WHERE  OR ', ' WHERE ');
            query += ' ORDER BY buildertek__Trade_Type__r.Name ASC , buildertek__Categories__r.Name ASC, buildertek__Product_Type__r.Name ASC, buildertek__Location__c ASC, buildertek__Quantity__c ASC';
            query += ' LIMIT : pageSize OFFSET : offset';
            productClassWrapper.takeOffLinesList = Database.query(query);

            query = 'Select COUNT() FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c =:takeOffId ' + filter;//Total records with Search Query filter.
            //query = query.replace(' WHERE  OR ', ' WHERE ');
            productClassWrapper.totalRecords = Database.countQuery(query);

            //SSTL
            query = 'Select Id,Name,buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Location__c, buildertek__Product_Type__c, buildertek__Product_Type__r.Name FROM buildertek__Select_Sheet__c WHERE ';
            filter = '';

            //Filter query based on Product2.
            for (Product2 product : productList){
                filter += product.buildertek__Trade_Type__c == null ? ' OR ( buildertek__Trade_Type__c = null' : ' OR ( buildertek__Trade_Type__c =\'' + product.buildertek__Trade_Type__c + '\'';
                filter += product.buildertek__Product_Type__c == null ? ' AND buildertek__Product_Type__c = null' : ' AND buildertek__Product_Type__c =\'' + product.buildertek__Product_Type__c + '\'';
                filter += product.buildertek__Category__c == null ? ' AND buildertek__Category__c = null' : ' AND buildertek__Category__c =\'' + product.buildertek__Category__c + '\'';
                filter += ' ) ';
            }
            query += filter;
            query = query.replace(' WHERE  OR ', ' WHERE ');
            query += ' ORDER BY buildertek__Trade_Type__r.Name ASC , buildertek__Category__r.Name ASC,buildertek__Vendor__r.Name ASC, buildertek__Product_Type__r.Name ASC, buildertek__Location__c ASC';
            query += ' LIMIT : pageSize OFFSET : offset';
            productClassWrapper.selectionSheetTakeOffLines = Database.query(query);
            //SSTL Count
            query = 'Select COUNT() FROM buildertek__Select_Sheet__c WHERE ' + filter;//Total records with Search Query filter.
            query = query.replace(' WHERE  OR ', ' WHERE ');
            productClassWrapper.SSTLTotalRecords = Database.countQuery(query);
            return productClassWrapper;
     //   } catch (Exception e){
     //       System.debug('Error Message::' + e.getMessage());
     //       System.debug('Error Line::' + e.getLineNumber());
    //        throw new AuraHandledException(e.getMessage());
     //   }
    }

    //Assign Product to the SSTL.
    @AuraEnabled
    public static String assignProductToSSTLRecord1(Integer productPageNumber, Integer productPageSize, Integer pageNumber, Integer pageSize, Integer SSTLPageNumber, Integer SSTLPageSize, String filteredTakeOffLines, String productId, List<String> selectedSSTL){
       // try{
            if (String.isNotBlank(productId) && selectedSSTL.size() > 0){
                Product2 productRec = [Select Id, Name
                                       FROM Product2
                                       WHERE Id = :productId
                                       LIMIT 1];
                List<buildertek__Select_Sheet__c> SSTLList = new List<buildertek__Select_Sheet__c>();
                for (String recId : selectedSSTL){
                    buildertek__Select_Sheet__c SSTL = new buildertek__Select_Sheet__c();
                    SSTL.buildertek__Product__c = productRec.Id;
                    // SSTL.Name = productRec.Name;
                    SSTL.Id = recId;
                    SSTLList.add(SSTL);
                }
                if (SSTLList.size() > 0){
                    update SSTLList;
                }
                return 'Success';
            }
            return null;
      //  } catch (Exception e){
      //      System.debug('Error Message::' + e.getMessage());
      //     System.debug('Error Line::' + e.getLineNumber());
            //throw new AuraHandledException(e.getMessage());
      // }
    }
    
    @AuraEnabled
    public static ProductClass createTakeOffLinesRecords(List<String> productIds, String recordId, Integer productPageNumber, Integer productPageSize, Integer pageSize, 
                                                         Integer pageNumber, Integer SSTLPageNumber, Integer SSTLPageSize,  String packageLinesSearchTradeType, 
                                                         String packageLinesSearchCategory, String packageLinesSearchProductType, String collection, String buildPhase, 
                                                         String tradeType, String category, String productType, String locationSearch, String tradeTypeSSTL, String categorySSTL, 
                                                         String productTypeSSTL, List<String> productIdList, List<String> takeOffLineList, String projectId){
        try{
            Map<String,String> LocationMap = new Map<String, String>();
            Map<String, String> takeOffLineMap = new Map<String, String>();
            Map<String, Decimal> quantityMap    = new Map<String, Decimal>();
            Map<String, String> buildPhaseMap = new Map<String, String>();
            if(takeOffLineList.size() > 0){
                List<buildertek__Project_Takeoff_Lines__c> takeOffLinesList = [SELECT Id, 
                                                                                        Name, 
                                                                                        buildertek__Location__c, 
                                                                                        buildertek__Quantity__c,
                                                                                        buildertek__Product_Type__c,
                                                                                        buildertek__Build_Phase__c,
                                                                                        buildertek__Build_Phase__r.Name
                                                                                        FROM buildertek__Project_Takeoff_Lines__c
                                                                                        WHERE Id IN: takeOffLineList];  
                system.debug('takeOffLinesList --------> '+takeOffLinesList);
                for(buildertek__Project_Takeoff_Lines__c takeOffLine : takeOffLinesList){
                    quantityMap.put(takeOffLine.buildertek__Product_Type__c,takeOffLine.buildertek__Quantity__c);
                    LocationMap.put(takeOffLine.buildertek__Product_Type__c, takeOffLine.buildertek__Location__c);
                    takeOffLineMap.put(takeOffLine.buildertek__Product_Type__c, takeOffLine.Id);
                    buildPhaseMap.put(takeOffLine.buildertek__Product_Type__c,takeOffLine.buildertek__Build_Phase__c);
                }
                system.debug(buildPhaseMap);
            }
            if (productIdList.size() > 0){
                List<Product2> productList = [Select Id, Name, buildertek__Category__c, buildertek__Instructions__c, buildertek__Trade_Type__c, buildertek__Product_Type__c, buildertek__Vendor__c
                                              FROM Product2
                                              WHERE Id IN :productIdList];
                system.debug('products size ----> '+productList.size());
                system.debug('productList for vendor'+productList);
                List<buildertek__Select_Sheet__c> selectionList = new List<buildertek__Select_Sheet__c>();
                if (productList.size() > 0 && takeOffLineList.size() > 0){
                    for (Product2 product : productList){
                        //for (String takeOffLineId : takeOffLineList){
                            buildertek__Select_Sheet__c SSTL = new buildertek__Select_Sheet__c();
                            SSTL.Name = product.Name;
                            SSTL.buildertek__Category__c = product.buildertek__Category__c;
                            SSTL.buildertek__Instructions__c = product.buildertek__Instructions__c;
                            SSTL.buildertek__Product_Type__c = product.buildertek__Product_Type__c;
                            SSTL.buildertek__Selection_Sheet_Takeoff__c = recordId;
                            SSTL.buildertek__Product__c = product.Id;
                            SSTL.buildertek__Trade_Type__c = product.buildertek__Trade_Type__c;
                            SSTL.buildertek__Project__c = projectId;
                            SSTL.buildertek__Vendor__c = product.buildertek__Vendor__c;
                            SSTL.buildertek__Takeoff_Line__c = takeOffLineMap.get(product.buildertek__Product_Type__c);
                            SSTL.buildertek__Standard__c = 'Yes';
                            SSTL.buildertek__Type__c = 'Standard';
                            SSTL.buildertek__Location_Picklist__c = LocationMap.get(product.buildertek__Product_Type__c);
                            SSTL.buildertek__Build_Phase__c = buildPhaseMap.get(product.buildertek__Product_Type__c);
                            SSTL.buildertek__Quantity__c = quantityMap.get(product.buildertek__Product_Type__c);
                            selectionList.add(SSTL);
                         system.debug(SSTL.buildertek__Build_Phase__c);
                        //}
                    }

                } else if (productList.size() > 0 && takeOffLineList.size() == 0){
                    for (Product2 product : productList){
                        buildertek__Select_Sheet__c SSTL = new buildertek__Select_Sheet__c();
                        SSTL.Name = product.Name;
                        SSTL.buildertek__Category__c = product.buildertek__Category__c;
                        SSTL.buildertek__Instructions__c = product.buildertek__Instructions__c;
                        SSTL.buildertek__Product_Type__c = product.buildertek__Product_Type__c;
                        SSTL.buildertek__Selection_Sheet_Takeoff__c = recordId;
                        SSTL.buildertek__Product__c = product.Id;
                        SSTL.buildertek__Trade_Type__c = product.buildertek__Trade_Type__c;
                        SSTL.buildertek__Project__c = projectId;
                        SSTL.buildertek__Vendor__c = product.buildertek__Vendor__c;
                        SSTL.buildertek__Standard__c = 'Yes';
                        SSTL.buildertek__Type__c = 'Standard';
                        SSTL.buildertek__Build_Phase__c = buildPhaseMap.get(product.buildertek__Product_Type__c);
                        SSTL.buildertek__Quantity__c = quantityMap.get(product.buildertek__Product_Type__c);
                        selectionList.add(SSTL);
                         system.debug(selectionList);
                    }
                }
               
                if (selectionList.size() > 0){
                    system.debug('selectionList size -----> '+selectionList.size());
                    insert selectionList;
                }
                return searchQueryResult2(recordId, productPageNumber, productPageSize, pageNumber, pageSize, SSTLPageNumber, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, buildPhase, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL);
            }
            return null;
        } catch (Exception e){
            System.debug('Error Message::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static ProductClass searchQueryResult2(String recordId, Integer productPageNumber, Integer productPageSize, Integer pageNumber, Integer pageSize, Integer SSTLPageNumber, 
                                                  Integer SSTLPageSize, String packageLinesSearchTradeType, String packageLinesSearchCategory, String packageLinesSearchProductType,
                                                  String collection, String buildPhase, String tradeType, String category, String productType, String locationSearch, String tradeTypeSSTL,
                                                  String categorySSTL, String productTypeSSTL){
        try{
            ProductClass productClassWrapper = new ProductClass();
            productClassWrapper.takeOffLinesList = new List<buildertek__Project_Takeoff_Lines__c>();
            productClassWrapper.productsRecord = new List<Product2>();
            //Base Query for Product2
            String query = '';
            String filter = '';
            String baseFilter = '';
            Boolean isFieldExist = false;
            Integer productOffset = (productPageNumber - 1) * productPageSize;//For Product
            Integer offset = (pageNumber - 1) * pageSize;//For SSTL
            Integer SSTLOffset = (SSTLPageNumber - 1) * SSTLPageSize;//For SSTL

            buildertek__Project_Selection_Sheet_Takeoff__c projectSelectionSheetTakeOff = [Select Id, Name, buildertek__Takeoff__c, buildertek__Project__c, buildertek__Project__r.Name, buildertek__Project__r.buildertek__Project_Tiers__c, buildertek__Project__r.buildertek__Plan_Type__c
                                                                                           FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                                           WHERE Id = :recordId
                                                                                           LIMIT 1];
            system.debug('projectSelectionSheetTakeOff:::::' + projectSelectionSheetTakeOff.buildertek__Takeoff__c);
            if(projectSelectionSheetTakeOff.buildertek__Takeoff__c != null ){
                string takeOffId = projectSelectionSheetTakeOff.buildertek__Takeoff__c;
            system.debug('takeOffId:::::' + takeOffId);
            }
            //TakeOff Lines
            query = 'Select Id,Name,buildertek__Project_Takeoff__c,buildertek__Categories__c, buildertek__Categories__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Location__c, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Quantity__c,buildertek__Build_Phase__c,buildertek__Build_Phase__r.Name FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c =:takeOffId ';
            filter = '';
            isFieldExist = false;
            if (String.isNotBlank(buildPhase)){
                buildPhase = '%' + buildPhase + '%';
                filter += ' AND buildertek__Build_Phase__r.Name LIKE :buildPhase';
                isFieldExist = true;
            }
            if (String.isNotBlank(tradeType)){
                tradeType = '%' + tradeType + '%';
                filter += ' AND buildertek__Trade_Type__r.Name LIKE :tradeType';
                isFieldExist = true;
            }
            if (String.isNotBlank(category)){
                category = '%' + category + '%';
                filter += ' AND buildertek__Categories__r.Name LIKE :category';
                isFieldExist = true;
            }
            if (String.isNotBlank(productType)){
                productType = '%' + productType + '%';
                filter += ' AND buildertek__Product_Type__r.Name LIKE :productType';
                isFieldExist = true;
            }
            if (String.isNotBlank(locationSearch)){
                locationSearch = '%' + locationSearch + '%';
                filter += ' AND buildertek__Location__c LIKE :locationSearch';
                isFieldExist = true;
            }
            query += filter;
            //query = isFieldExist ? query.replace('WHERE  AND', ' WHERE ') : query.replace('WHERE ', '');
            query += ' ORDER BY  buildertek__Trade_Type__r.Name ASC NULLS LAST , buildertek__Categories__r.Name ASC NULLS LAST, buildertek__Product_Type__r.Name ASC NULLS LAST, buildertek__Location__c ASC NULLS LAST, buildertek__Quantity__c ASC NULLS LAST';
            query += ' LIMIT : pageSize OFFSET : offset';
            system.debug('query:11::' + query);
            productClassWrapper.takeOffLinesList = Database.query(query);
            system.debug('productClassWrapper.takeOffLinesList:11::' + productClassWrapper.takeOffLinesList);

            query = 'Select COUNT() FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c =:takeOffId ' + filter;//Total records with Search Query filter.
            //query = isFieldExist ? query.replace('WHERE  AND', ' WHERE ') : query.replace('WHERE ', '');
            system.debug('query:22::' + query);
            productClassWrapper.totalRecords = Database.countQuery(query);
            if (productClassWrapper.takeOffLinesList.size() > 0){
                //Product2 Query
                query = 'SELECT Id, Name, buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Series__c ,buildertek__Cost_Code__r.Name, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Vendor__r.Name,StockKeepingUnit FROM Product2';
                query += ' WHERE';
                filter = '';
                for (buildertek__Project_Takeoff_Lines__c takeOffLines : productClassWrapper.takeOffLinesList){
                   // filter += takeOffLines.buildertek__Build_Phase__c == null ? ' OR ( buildertek__Build_Phase__c = null' : ' OR ( buildertek__Build_Phase__c =\'' + takeOffLines.buildertek__Build_Phase__c + '\'';
                    filter += takeOffLines.buildertek__Trade_Type__c == null ? ' OR ( buildertek__Trade_Type__c = null' : ' OR ( buildertek__Trade_Type__c =\'' + takeOffLines.buildertek__Trade_Type__c + '\'';
                    filter += takeOffLines.buildertek__Product_Type__c == null ? ' AND buildertek__Product_Type__c = null' : ' AND buildertek__Product_Type__c =\'' + takeOffLines.buildertek__Product_Type__c + '\'';
                    filter += takeOffLines.buildertek__Categories__c == null ? ' AND buildertek__Category__c = null' : ' AND buildertek__Category__c =\'' + takeOffLines.buildertek__Categories__c + '\'';
                    filter += projectSelectionSheetTakeOff.buildertek__Project__r == null || projectSelectionSheetTakeOff.buildertek__Project__r.buildertek__Project_Tiers__c == null ? ' AND buildertek__Collection__c = null' : ' AND buildertek__Collection__c =\'' + projectSelectionSheetTakeOff.buildertek__Project__r.buildertek__Project_Tiers__c + '\'';
                    
                    if (String.isNotBlank(packageLinesSearchTradeType)){
                        packageLinesSearchTradeType = '%' + packageLinesSearchTradeType + '%';
                        filter += ' AND buildertek__Trade_Type__r.Name LIKE :packageLinesSearchTradeType';
                    }
                    if (String.isNotBlank(packageLinesSearchCategory)){
                        packageLinesSearchCategory = '%' + packageLinesSearchCategory + '%';
                        filter += ' AND buildertek__Category__r.Name LIKE :packageLinesSearchCategory';
                    }
                    if (String.isNotBlank(packageLinesSearchProductType)){
                        packageLinesSearchProductType = '%' + packageLinesSearchProductType + '%';
                        filter += ' AND buildertek__Product_Type__r.Name LIKE :packageLinesSearchProductType';
                    }
                    filter += ' ) ' ;
                }
                query += filter;
                query = productClassWrapper.takeOffLinesList.size() > 0 ? query.replace('WHERE OR', 'WHERE ') : query.replace('WHERE', ' ');
                query += ' ORDER BY  buildertek__Trade_Type__r.Name ASC NULLS LAST, buildertek__Category__r.Name ASC NULLS LAST, buildertek__Product_Type__r.Name ASC NULLS LAST';
                query += ' LIMIT : productPageSize OFFSET : productOffset';
                //Retrieve Product2
                System.debug('Product Query : ' + query);
                productClassWrapper.productsRecord = Database.query(query);
                system.debug('productClassWrapper.productsRecord:::::='+productClassWrapper.productsRecord);
                query = 'Select COUNT() FROM Product2 WHERE';
                query += filter;
                query = productClassWrapper.takeOffLinesList.size() > 0 ? query.replace(' WHERE OR ', ' WHERE ') : query.replace(' WHERE', ' ');
                productClassWrapper.productTotalRecords = Database.countQuery(query);
                system.debug('productClassWrapper.productsRecord:::;'+productClassWrapper.productsRecord);

            }

            //SSTL
            if (productClassWrapper.productsRecord.size() > 0){
                query = 'Select Id,Name, buildertek__Takeoff_Line__c, buildertek__Takeoff_Line__r.Name, buildertek__Location__c, buildertek__Quantity__c,buildertek__Product__c,buildertek__Product__r.Name , buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Vendor__r.Name, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Build_Phase__c,buildertek__Build_Phase__r.Name FROM buildertek__Select_Sheet__c WHERE ';
                filter = '';
                isFieldExist = false;
                //Filter query based on Product2.
                for (Product2 product : productClassWrapper.productsRecord){
                    filter += product.buildertek__Trade_Type__c == null ? ' OR ( buildertek__Trade_Type__c = null' : ' OR ( buildertek__Trade_Type__c =\'' + product.buildertek__Trade_Type__c + '\'';
                    filter += product.buildertek__Product_Type__c == null ? ' AND buildertek__Product_Type__c = null' : ' AND buildertek__Product_Type__c =\'' + product.buildertek__Product_Type__c + '\'';
                    filter += product.buildertek__Category__c == null ? ' AND buildertek__Category__c = null' : ' AND buildertek__Category__c =\'' + product.buildertek__Category__c + '\'';
                    if (String.isNotBlank(tradeTypeSSTL)){
                        tradeTypeSSTL = '%' + tradeTypeSSTL + '%';
                        filter += ' AND buildertek__Trade_Type__r.Name LIKE :tradeTypeSSTL';
                        isFieldExist = true;
                    }
                    if (String.isNotBlank(categorySSTL)){
                        categorySSTL = '%' + categorySSTL + '%';
                        filter += ' AND buildertek__Category__r.Name LIKE :categorySSTL';
                        isFieldExist = true;
                    }
                    if (String.isNotBlank(productTypeSSTL)){
                        productTypeSSTL = '%' + productTypeSSTL + '%';
                        filter += ' AND buildertek__Product_Type__r.Name LIKE :productTypeSSTL';
                        isFieldExist = true;
                    }
                    filter += ' ) ';
                }
                query += filter;
                if (productClassWrapper.productsRecord.size() > 0){
                    query = query.replace('WHERE  OR', ' WHERE ');
                    query += ' ORDER BY buildertek__Build_Phase__r.Name ASC NULLS LAST , buildertek__Trade_Type__r.Name ASC NULLS LAST , buildertek__Category__r.Name ASC NULLS LAST, buildertek__Product_Type__r.Name ASC NULLS LAST,buildertek__Vendor__r.Name ASC NULLS LAST, buildertek__Location__c ASC NULLS LAST';
                    query += ' LIMIT : SSTLPageSize OFFSET : SSTLOffset';
                    productClassWrapper.selectionSheetTakeOffLines = Database.query(query);
                    system.debug(productClassWrapper.selectionSheetTakeOffLines);
                    query = 'Select COUNT() FROM buildertek__Select_Sheet__c WHERE ' + filter;//Total records with Search Query filter.
                    query = productClassWrapper.productsRecord.size() > 0 ? query.replace('WHERE  OR', ' WHERE ') : query.replace('WHERE ', ' ');
                    productClassWrapper.SSTLTotalRecords = Database.countQuery(query);
                } else{
                    productClassWrapper.selectionSheetTakeOffLines = new List<buildertek__Select_Sheet__c>();
                    productClassWrapper.SSTLTotalRecords = 0;

                }

            }
        
            return productClassWrapper;
        
        } catch (Exception e){
            System.debug('Error Message::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
            
        }
    }

    @AuraEnabled
    public static ProductClass retrieveProductRecords(String recordId, Integer productPageNumber, Integer productPageSize, Integer pageNumber, 
                                                      Integer pageSize, Integer SSTLPageNumber, Integer SSTLPageSize , String packageLinesSearchTradeType, 
                                                      String packageLinesSearchCategory, String packageLinesSearchProductType, String collection, String buildPhase, 
                                                      String tradeType, String category, String productType, String locationSearch, String tradeTypeSSTL, String categorySSTL,
                                                      String productTypeSSTL, String filteredTakeOffLines){
        try{
            List<buildertek__Project_Takeoff_Lines__c> filteredTakeOffLineList = (List<buildertek__Project_Takeoff_Lines__c>)JSON.deserialize(filteredTakeOffLines, List<buildertek__Project_Takeoff_Lines__c>.class);
            system.debug('filteredTakeOffLineList::'+filteredTakeOffLineList);
            ProductClass productClassWrapper = new ProductClass();
            productClassWrapper.selectionSheetTakeOffLines = new List<buildertek__Select_Sheet__c>();
            productClassWrapper.takeOffLinesList = new List<buildertek__Project_Takeoff_Lines__c>();
            productClassWrapper.productsRecord = new List<Product2>();

            //Base Query for Product2
            String query = '';
            String filter = '';
            String baseFilter = '';
            Boolean isFieldExist = false;
            Integer productOffset = (productPageNumber - 1) * productPageSize;//For Product
            Integer offset = (pageNumber - 1) * pageSize;//For SSTL
            Integer SSTLOffset = (SSTLPageNumber - 1) * SSTLPageSize;//For SSTL

            buildertek__Project_Selection_Sheet_Takeoff__c projectSelectionSheetTakeOff = [Select Id, Name, buildertek__Project__c, buildertek__Project__r.Name, buildertek__Project__r.buildertek__Project_Tiers__c, buildertek__Project__r.buildertek__Plan_Type__c
                                                                                           FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                                           WHERE Id = :recordId
                                                                                           LIMIT 1];
            if (filteredTakeOffLineList.size() > 0){
                //Product2 Query
                query = 'SELECT Id, Name, buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c,buildertek__Series__c ,buildertek__Cost_Code__r.Name, buildertek__Trade_Type__r.Name,  buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Vendor__r.Name,StockKeepingUnit FROM Product2';
                query += ' WHERE';
                filter = '';
                for (buildertek__Project_Takeoff_Lines__c takeOffLines : filteredTakeOffLineList){
                    filter += takeOffLines.buildertek__Trade_Type__c == null ? ' OR ( buildertek__Trade_Type__c = null' : ' OR ( buildertek__Trade_Type__c =\'' + takeOffLines.buildertek__Trade_Type__c + '\'';
                    filter += takeOffLines.buildertek__Product_Type__c == null ? ' AND buildertek__Product_Type__c = null' : ' AND buildertek__Product_Type__c =\'' + takeOffLines.buildertek__Product_Type__c + '\'';
                    filter += takeOffLines.buildertek__Categories__c == null ? ' AND buildertek__Category__c = null' : ' AND buildertek__Category__c =\'' + takeOffLines.buildertek__Categories__c + '\'';
                    filter += projectSelectionSheetTakeOff.buildertek__Project__r == null || projectSelectionSheetTakeOff.buildertek__Project__r.buildertek__Project_Tiers__c == null ? ' AND buildertek__Collection__c = null' : ' AND buildertek__Collection__c =\'' + projectSelectionSheetTakeOff.buildertek__Project__r.buildertek__Project_Tiers__c + '\'';


                    if (String.isNotBlank(packageLinesSearchTradeType)){
                        packageLinesSearchTradeType = '%' + packageLinesSearchTradeType + '%';
                        filter += ' AND buildertek__Trade_Type__r.Name LIKE :packageLinesSearchTradeType';
                    }
                    if (String.isNotBlank(packageLinesSearchCategory)){
                        packageLinesSearchCategory = '%' + packageLinesSearchCategory + '%';
                        filter += ' AND buildertek__Category__r.Name LIKE :packageLinesSearchCategory';
                    }
                    if (String.isNotBlank(packageLinesSearchProductType)){
                        packageLinesSearchProductType = '%' + packageLinesSearchProductType + '%';
                        filter += ' AND buildertek__Product_Type__r.Name LIKE :packageLinesSearchProductType';
                    }
                    filter += ' ) ';
                }
                query += filter;
                query = filteredTakeOffLineList.size() > 0 ? query.replace('WHERE OR', 'WHERE ') : query.replace('WHERE', ' ');
                query += ' ORDER BY buildertek__Trade_Type__r.Name ASC NULLS LAST, buildertek__Category__r.Name ASC NULLS LAST, buildertek__Product_Type__r.Name ASC NULLS LAST';
                query += ' LIMIT : productPageSize OFFSET : productOffset';
                //Retrieve Product2
                System.debug('Product Query : ' + query);
                productClassWrapper.productsRecord = Database.query(query);
                query = 'Select COUNT() FROM Product2 WHERE';
                query += filter;
                query = filteredTakeOffLineList.size() > 0 ? query.replace(' WHERE OR ', ' WHERE ') : query.replace(' WHERE', ' ');
                productClassWrapper.productTotalRecords = Database.countQuery(query);

                if (productClassWrapper.productsRecord.size() > 0){
                    //SSTL
                    query = 'Select Id,Name,buildertek__Product__r.Name,buildertek__Takeoff_Line__r.Name, buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Location__c, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Build_Phase__c,buildertek__Build_Phase__r.Name FROM buildertek__Select_Sheet__c WHERE ';
                    filter = '';
                    isFieldExist = false;
                    //Filter query based on Product2.
                    for (Product2 product : productClassWrapper.productsRecord){
                        filter += product.buildertek__Trade_Type__c == null ? ' OR ( buildertek__Trade_Type__c = null' : ' OR ( buildertek__Trade_Type__c =\'' + product.buildertek__Trade_Type__c + '\'';
                        filter += product.buildertek__Product_Type__c == null ? ' AND buildertek__Product_Type__c = null' : ' AND buildertek__Product_Type__c =\'' + product.buildertek__Product_Type__c + '\'';
                        filter += product.buildertek__Category__c == null ? ' AND buildertek__Category__c = null' : ' AND buildertek__Category__c =\'' + product.buildertek__Category__c + '\'';
                        if (String.isNotBlank(tradeTypeSSTL)){
                            tradeTypeSSTL = '%' + tradeTypeSSTL + '%';
                            filter += ' AND buildertek__Trade_Type__r.Name LIKE :tradeTypeSSTL';
                            isFieldExist = true;
                        }
                        if (String.isNotBlank(categorySSTL)){
                            categorySSTL = '%' + categorySSTL + '%';
                            filter += ' AND buildertek__Category__r.Name LIKE :categorySSTL';
                            isFieldExist = true;
                        }
                        if (String.isNotBlank(productTypeSSTL)){
                            productTypeSSTL = '%' + productTypeSSTL + '%';
                            filter += ' AND buildertek__Product_Type__r.Name LIKE :productTypeSSTL';
                            isFieldExist = true;
                        }
                        filter += ' ) ';
                    }
                    query += filter;
                    if (productClassWrapper.productsRecord.size() > 0){
                        query = query.replace('WHERE  OR', ' WHERE ');
                        query += ' ORDER BY buildertek__Trade_Type__r.Name ASC NULLS LAST , buildertek__Category__r.Name ASC NULLS LAST, buildertek__Product_Type__r.Name ASC NULLS LAST,buildertek__Vendor__r.Name ASC NULLS LAST, buildertek__Location__c ASC NULLS LAST';
                        query += ' LIMIT : SSTLPageSize OFFSET : SSTLOffset';
                        productClassWrapper.selectionSheetTakeOffLines = Database.query(query);
                        query = 'Select COUNT() FROM buildertek__Select_Sheet__c WHERE ' + filter;//Total records with Search Query filter.
                        query = productClassWrapper.productsRecord.size() > 0 ? query.replace('WHERE  OR', ' WHERE ') : query.replace('WHERE ', ' ');
                        productClassWrapper.SSTLTotalRecords = Database.countQuery(query);
                    } else{
                        productClassWrapper.selectionSheetTakeOffLines = new List<buildertek__Select_Sheet__c>();
                        productClassWrapper.SSTLTotalRecords = 0;
                    }

                }

            }


            return productClassWrapper;
        } catch (Exception e){
            System.debug('Error Message::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static ProductClass deleteSelectedSSTLRecord(String recordId, Integer productPageNumber, Integer productPageSize, Integer pageNumber, 
                                                        Integer pageSize, Integer SSTLPageNumber, Integer SSTLPageSize, String packageLinesSearchTradeType, 
                                                        String packageLinesSearchCategory, String packageLinesSearchProductType, String collection, String buildPhase,
                                                        String tradeType, String category, String productType, String locationSearch,  String tradeTypeSSTL, String categorySSTL, 
                                                        String productTypeSSTL, String deleteSSTLIds){
        try{
            System.debug('Delete Id::' + deleteSSTLIds);
            if (String.isNotBlank(deleteSSTLIds)){
                delete [Select Id
                        FROM buildertek__Select_Sheet__c
                        WHERE ID = :deleteSSTLIds];
            }
            return searchQueryResult2(recordId, productPageNumber, productPageSize, pageNumber, pageSize, SSTLPageNumber, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection,buildPhase, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL);
        } catch (Exception e){
            System.debug('Error Message::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    //Get All products
    @AuraEnabled
    public static String getImages(String recordId){
        try{
            if (String.isNotBlank(recordId)){
                Set<Id> conDocIdSet = new Set<Id>();
                for (ContentDocumentLink contDocLink : [Select Id, ContentDocumentId
                                                        FROM ContentDocumentLink
                                                        WHERE LinkedEntityId = :recordId]){
                    conDocIdSet.add(contDocLink.ContentDocumentId);
                }
                if (conDocIdSet.size() > 0){
                    List<ContentVersion> conVerRecords = [Select Id
                                                          FROM ContentVersion
                                                          WHERE ContentDocumentId In :conDocIdSet AND FileExtension != 'pdf'];
                    return conVerRecords.size() > 0 ? JSON.serialize(conVerRecords) : '[]';
                }
            }
            return null;
        } catch (Exception e){
            System.debug('Error Message::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ProjectTakeOffWrapper{
        @AuraEnabled
        public List<Product2> records{ get; set; }

        @AuraEnabled
        public List<LocationWrapper> locationDropDown;
        @AuraEnabled
        public Integer totalRecords;
    }

    public class LocationWrapper{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }

    public class ProductClass{
        @AuraEnabled
        public buildertek__Project_Selection_Sheet_Takeoff__c projectSelectionSheetTakeOffRec;

        @AuraEnabled
        public List<Product2> productsRecord{ get; set; }

        @AuraEnabled
        public List<buildertek__Project_Takeoff_Lines__c> takeOffLinesList{ get; set; }

        @AuraEnabled
        public List<buildertek__Select_Sheet__c> selectionSheetTakeOffLines{ get; set; }

        @AuraEnabled
        public Integer productTotalRecords;
        @AuraEnabled
        public Integer totalRecords;
        @AuraEnabled
        public Integer SSTLTotalRecords;
    }

    public class ProjectRecordDetails{
        @AuraEnabled
        public buildertek__Project__c projectRec;

    }

    public class MessageClass{
        @AuraEnabled
        public String Status{ get; set; }

        @AuraEnabled
        public string Message{ get; set; }
    }
}