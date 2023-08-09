/*
    Developed By: Laxman B
    Date:  09-09-2020.

*/


global  without sharing class QuotelineswithGroupingNameController {

   // global string relatedToId {get;set;}
    global string quoteid;
    global string RollupAllGroupName {get;set;}

    global string queryfields ;
    global list<buildertek__Quote_Item__c> dynamicQuoteItem {get;set;}
    global list<buildertek__Quote_Item__c> QuoteItem;
    global list<buildertek__Quote_Line_Group__c> Quotelinegroup ;
    global map<id,list<buildertek__Quote_Item__c>> quotegroupingmap;
    global decimal Totalquotelineamount {get;set;}
    global list<wrapperClass> wrapperlst {get;set;}
    global list<buildertek__Quote__c> quotesList{get;set;}
    global integer colomspanvalue {get;set;}
    global list<string> sorlableslst {get;set;}

    global QuotelineswithGroupingNameController(){
        quotesList = new list<buildertek__Quote__c>();
        QuoteItem = new list<buildertek__Quote_Item__c>();
        dynamicQuoteItem = new list<buildertek__Quote_Item__c>();
        Quotelinegroup = new list<buildertek__Quote_Line_Group__c>();
    }
    global void setquerystring(string querystring){
        this.queryfields = querystring;

       //Quotelinegroupingdata();
    }
    global string getquerystring (){
        return queryfields;
    }
     global void setrelatedToId(string Id){
        this.quoteid = Id;
       Quotelinegroupingdata();
    }
    global string getrelatedToId( ){
        return quoteid;
    }
    global  String mylabel;
    global list<string> lablevalueslst {get;set;}
    global list<string> lableslst {get;set;}
    global map<string,string> sortlablevalueMap {get;set;}
    global void Quotelinegroupingdata() {
        lablevalueslst = new list<string> ();
        sortlablevalueMap = new map<string,string>();
      system.debug('quoteid------>'+quoteid);
        system.debug('querystringfields--------------->'+queryfields);

         wrapperlst = new list<wrapperClass>();
         Totalquotelineamount = 0.0;
        string query = 'Select '+ queryfields ;
        string statusval = 'Accept';
        query += ' from buildertek__Quote_Item__c where buildertek__Quote__c = \''+quoteid +'\' AND buildertek__Status__c =\''+ statusval +'\''+'Order By buildertek__Priority__c ASC';
        system.debug('query---->'+query);
         lableslst = queryfields.split(',');
        colomspanvalue = lableslst.size()-1;
        //String type= 'buildertek__Quote_Item__c';  // Say,this is my object
        system.debug('lableslst--->'+lableslst);

        String type= 'buildertek__Quote_Item__c';  // Say,this is my object
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        for (String fieldName: fieldMap.keySet()) {
            String mylabel=fieldMap.get(fieldName).getDescribe().getLabel();
             for (String lablerec: lableslst) {
                 system.debug('-label---'+lablerec+'--field---->'+fieldName);
                 if(lablerec == fieldName){
                     lablevalueslst.add(mylabel);
                     sortlablevalueMap.put(lablerec,mylabel);
                 }
             }
        }


        system.debug('lablevalueslst--->'+lablevalueslst);
        if(query !=null){
         dynamicQuoteItem = Database.query(query);
        system.debug('dynamicQuoteItem--->'+dynamicQuoteItem);
        }
         quotesList  = [ select id,
                            buildertek__Project__c ,
                            buildertek__Roll_Up__c,
                            buildertek__Rollup_by_Group__c,
                        	buildertek__Subtotal__c,
                            Total__c,
                            Tax__c,
                            Grand_Total__c,
                        	buildertek__Discount__c
                            from buildertek__Quote__c
                            where id =: quoteid limit 1];

                   // Initialize setup variables
                        String objectName = 'buildertek__Quote_Item__c';  // modify as needed
                    String quoteitemquery = 'SELECT';
                    Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

                    // Grab the fields from the describe method and append them to the queryString one by one.
                    for(String s : objectFields.keySet()) {
                        quoteitemquery += ' ' + s + ', ';
                    }

                    // Manually add related object's fields that are needed.
                    quoteitemquery += 'buildertek__Grouping__r.Name,buildertek__Cost_Code__r.Name,buildertek__Quote__r.Name,buildertek__Product__r.Name,buildertek__Purchase_Order__r.Name,buildertek__Vendor__r.Name'; // modify as needed

                    // Strip off the last comma if it exists.
                    if (quoteitemquery.subString(quoteitemquery.Length()-1,quoteitemquery.Length()) == ','){
                        quoteitemquery = quoteitemquery.subString(0,quoteitemquery.Length()-1);
                    }

                    // Add FROM statement
                    quoteitemquery += ' FROM ' + objectName;

                    // Add on a WHERE/ORDER/LIMIT statement as needed
                    quoteitemquery += ' WHERE buildertek__Quote__c = \''+quoteid +'\' AND buildertek__Status__c =\''+ statusval +'\''+ ' Order BY buildertek__Priority__c ASC'; // modify as needed

                    try {
                        QuoteItem = database.query(quoteitemquery);
                    } catch (QueryException e){
                        //perform exception handling
                    }
       /*  QuoteItem = [select Id,Name,buildertek__Product__c,
                      buildertek__Quote__c,
                      buildertek__Quote__r.name,
                      buildertek__Grouping__c,
                      buildertek__Grouping__r.Name,
                      buildertek__Unit_Cost__c,
                      buildertek__Unit_Price__c,
                      buildertek__Net_Unit__c,
                      buildertek__Total_Cost__c,
                      buildertek__List_Total__c,
                      buildertek__Net_Total_Price__c,
                      buildertek__Gross_Profit__c,
                      buildertek__Quantity__c,
                      buildertek__Status__c,
                      buildertek__Discount__c
                      from buildertek__Quote_Item__c
                      where buildertek__Quote__c = : quoteid AND buildertek__Status__c =:'Accept']; */

          system.debug('QuoteItem---->'+ QuoteItem.size());
        set<Id> groupid = new set<Id>();
        quotegroupingmap = new map<id,list<buildertek__Quote_Item__c>>();
        for(buildertek__Quote_Item__c qutitem : QuoteItem ){
            if(!quotegroupingmap.containsKey(qutitem.buildertek__Grouping__c)){
                    quotegroupingmap.put(qutitem.buildertek__Grouping__c, new list<buildertek__Quote_Item__c>());
                }
                quotegroupingmap.get(qutitem.buildertek__Grouping__c).add(qutitem);

            if(qutitem.buildertek__Grouping__c !=null){
            groupid.add(qutitem.buildertek__Grouping__c);
            }
        }

        Quotelinegroup = [Select Id, Name from buildertek__Quote_Line_Group__c where Id =: groupId order by Name asc];
        system.debug('Quotelinegroupsize---->'+ Quotelinegroup.size());

        for(buildertek__Quote_Line_Group__c quotelinegrouprec : Quotelinegroup){

             decimal quoteitemNetunitprice =0.0;
            decimal quoteitemlistTotal = 0.0;
            wrapperClass wrap = new wrapperClass();
            wrap.groupName = quotelinegrouprec.Name;
             wrap.quotelineitemlst = quotegroupingmap.get(quotelinegrouprec.Id);
            for(buildertek__Quote_Item__c quoteitemrec : quotegroupingmap.get(quotelinegrouprec.Id)){
                 if(quoteitemrec.buildertek__Net_Unit__c != null){
                     quoteitemNetunitprice += quoteitemrec.buildertek__Net_Unit__c;
                 }
                 if(quoteitemrec.buildertek__Net_Total_Price__c !=null){
                     quoteitemlistTotal += quoteitemrec.buildertek__Net_Total_Price__c;
                 }

            }
            wrap.netunitprice = quoteitemNetunitprice;
            wrap.listTotal = quoteitemlistTotal;

            wrapperlst.add(wrap);
         }

         system.debug(wrapperlst.size()+'wrapperlst----->'+wrapperlst);
        }



     global class wrapperClass {
        global String groupName { get; set; }
        global decimal netunitprice { get; set; }
        global decimal listTotal { get; set; }
        global list<buildertek__Quote_Item__c> quotelineitemlst { get; set; }
         global list<string> labelnames {get;set;}
         global list<string> fieldsapiname {get;set;}
     }



}