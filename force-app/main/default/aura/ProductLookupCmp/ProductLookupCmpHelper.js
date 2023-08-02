/*
	@ PURPOSE : 1. PROVIDES SERVICE TO => ProductLookupCmpController.js
				2. MAKES CALLS TO APEX SERVER.
	@ Name    : ProductLookupCmpHelper.js
*/
({
    showToastMessage : function( type, title, message ) {
        
        if( type && title && message ) {
            var toastEvent = $A.get( "e.force:showToast" );
            
            if( toastEvent ) {
                toastEvent.setParams({
                    'type' : type,
                    'title' : title,
                    'message': message,
                    'mode' : 'dismissible',
                    'duration' : 7000
                });
                toastEvent.fire();
            }
        }
    },
    
    closeModal : function( component ) {
        
        component.destroy();
    },
    
    handleProductSelect : function( component, helper, index, listOfSearchedResults ) {
        
        console.log( 'handleProductSelect-index', index );
        console.log( 'handleProductSelect-listOfSearchedResults', listOfSearchedResults );
        if( !listOfSearchedResults || listOfSearchedResults.length <= index ) {
            return;
        }
        
        var recordProductWrapper = listOfSearchedResults[ index ];
        console.log( 'handleProductSelect-recordProductWrapper', recordProductWrapper );
        if( !recordProductWrapper || !recordProductWrapper.recordProduct || !recordProductWrapper.recordProduct.Id ) {
            return;
        }
        
        var recordIndex = JSON.parse( JSON.stringify( component.get( "v.recordIndex" ) ) );
        var listName = JSON.parse( JSON.stringify( component.get( "v.listName" ) ) );
        var fieldName = JSON.parse( JSON.stringify( component.get( "v.fieldName" ) ) );
        
        if(component.get("v.componentName") === 'IGU'){
            console.log('Record Index IGU ',recordIndex + ' List name ', listName + ' Field name '+fieldName);
            var IGUprdRecordSelectEvt = component.getEvent( "IGUprdRecordSelectEvt" );
            if( !IGUprdRecordSelectEvt ) {
                return;
            }
            IGUprdRecordSelectEvt.setParams({
                'recordIndex' : recordIndex,
                'listName' : listName,
                'fieldName' : fieldName,
                'recordProductWrapper' : recordProductWrapper
            });
            IGUprdRecordSelectEvt.fire();
        }
        else if(component.get("v.componentName") === 'CHW'){
            console.log('Record Index CHW ',recordIndex + ' List name ', listName + ' Field name '+fieldName);
            var CHWprdRecordSelectEvt = component.getEvent( "CHWprdRecordSelectEvt" );
            if( !CHWprdRecordSelectEvt ) {
                return;
            }
            CHWprdRecordSelectEvt.setParams({
                'recordIndex' : recordIndex,
                'listName' : listName,
                'fieldName' : fieldName,
                'recordProductWrapper' : recordProductWrapper
            });
            CHWprdRecordSelectEvt.fire();
        }
            else{
                console.log('Record Index CHW ',recordIndex + ' List name ', listName + ' Field name '+fieldName);
            var productRecordSelectEvt = component.getEvent( "productRecordSelectEvt" );
            console.log( 'handleProductSelect-productRecordSelectEvt', productRecordSelectEvt );
            if( !productRecordSelectEvt ) {
                return;
            }
            productRecordSelectEvt.setParams({
                'recordIndex' : recordIndex,
                'listName' : listName,
                'fieldName' : fieldName,
                'recordProductWrapper' : recordProductWrapper
            });
            productRecordSelectEvt.fire(); 
        }
        helper.closeModal( component );
    },
    
    getProducts : function( component, helper, searchKeyword, opportunityPricebook2Id, productFamily, currencyIsoCode ) {
        
        console.log( 'getProducts-searchKeyword', searchKeyword );
        if( !searchKeyword || searchKeyword.length <= 2 ) {
            return;
        }
        component.set( "v.listOfSearchedResults", [] );
        console.log( 'getProducts-opportunityPricebook2Id', opportunityPricebook2Id );
        if( !opportunityPricebook2Id || !productFamily ) {
            return;
        }
        
        if( !currencyIsoCode ) {
            currencyIsoCode = 'USD';
        }	
        
        var serverAction = component.get( "c.searchProductRecords" );
        if( !serverAction ) {
            return;
        }
        component.set( "v.showSpinner", true );
        
        serverAction.setParams({ 
            "searchKeyword" : searchKeyword,
            "opportunityPricebook2Id" : opportunityPricebook2Id,
            "productFamily" : productFamily,
            "currencyIsoCode" : currencyIsoCode
        });
        
        serverAction.setCallback( this, function( response ) {
            
            component.set( "v.showSpinner", false );
            
            var state = response.getState();
            if ( state === "SUCCESS" ) {
                
                var result = JSON.parse( response.getReturnValue() );
                console.log( "getProducts", result );
                
                if( result.isSucceeded ) {
                    component.set( "v.listOfSearchedResults", result.listOfSearchedResults );
                }
                else {
                    helper.showToastMessage( 'error', 'Error!', result.message );
                }
            }
            else {
                helper.showToastMessage( 'error', 'Error!',$A.get("$Label.c.Something_Went_Wrong_Please_Contact_Admin"));
            }
        });
        
        $A.enqueueAction( serverAction );
    },
    
    getTrunkProducts : function(component,helper,searchKeyword)
    {
        var action = component.get("c.searchDB");
        console.log('Search Produ ',searchKeyword);
        action.setParams({searchText : searchKeyword});
        action.setCallback(this,function(response){
            var state = response.getState();
            if ( state === "SUCCESS" ) {
                
                var result = JSON.parse( response.getReturnValue() );
                console.log( "getProducts", result );
                
                if( result.isSucceeded ) {
                    component.set( "v.listOfSearchedResults", result.listOfSearchedResultsTrunk );
               }
                else {
                    helper.showToastMessage( 'error', 'Error!', result.message );
                }
            }
            else {
                helper.showToastMessage( 'error', 'Error!',$A.get("$Label.c.Something_Went_Wrong_Please_Contact_Admin"));
            }
        });
        $A.enqueueAction( action );
    },
})