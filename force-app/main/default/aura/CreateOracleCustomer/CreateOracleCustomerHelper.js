({
    getAccountData : function(component, event, helper) {
        var action = component.get('c.getAccountData');
        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var account = response.getReturnValue();
                component.set('v.account', account);
                helper.helperMethodJS(component, event, helper);
            } else if(state === 'ERROR'){
                helper.openModel(component,"An unexpected error has occured, please cntact the Admin","Error");
            }
        });
        $A.enqueueAction(action);
    },
    helperMethodJS : function(component, event, helper) {
        var country = 
            [ "United States","Canada", "United Kingdom", "Kuwait", "Saudi Arabia", "Switzerland", "Azerbaijan", "Afghanistan", "Aland Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "BIslands", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Anguilla", "Antarctica", "Antigua and ermuda", "Bhutan", "Bolivia, Plurinational State of", "Bosnia and Herzegovina", "Botswana", "Bouvet Island", "Brazil", "British Indian Ocean Territory", "Brunei Darussalam", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Cape Verde", "Cayman Islands", "Central African Republic", "Chad", "Chile", "China", "Christmas Island", "Cocos (Keeling) Islands", "Colombia", "Comoros", "Congo", "Congo, The Democratic Republic of the", "Cook Islands", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cuba", "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Falkland Islands (Malvinas)", "Faroe Islands", "Fiji", "Finland", "France", "French Guiana", "French Polynesia", "French Southern Territories", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Gibraltar", "Greece", "Greenland", "Grenada", "Guadeloupe", "Guam", "Guatemala", "Guernsey", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Heard Island and McDonald Islands", "Holy See (Vatican City State)", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran, Islamic Republic of", "Iraq", "Ireland", "Isle of Man", "Israel", "Italy", "Jamaica", "Japan", "Jersey", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Korea, Democratic People's Republic of", "Korea, Republic of", "Kyrgyzstan", "Lao People's Democratic Republic", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libyan Arab Jamahiriya", "Liechtenstein", "Lithuania", "Luxembourg", "Macao", "Macedonia, The Former Yugoslav Republic of", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Martinique", "Mauritania", "Mauritius", "Mayotte", "Mexico", "Micronesia, Federated States of", "Moldova", "Monaco", "Mongolia", "Montenegro", "Montserrat", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nauru", "Nepal", "Netherlands", "Netherlands Antilles", "New Caledonia", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Niue", "Norfolk Island", "Northern Mariana Islands", "Norway", "Obsolete see CD territory", "Obsolete see CS territory", "Obsolete see FR territory", "Obsolete see LT territory", "Obsolete see RS or ME territory", "Obsolete see TL territory", "Oman", "Pakistan", "Palau", "Palestinian Territory,Occupied", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Pitcairn", "Poland", "Portugal", "Puerto Rico", "Qatar", "Reunion", "Romania", "Russian Federation", "Rwanda", "Saint Barthelemy", "Saint Helena", "Saint Kitts and Nevis", "Saint Lucia", "Saint Martin (French part)", "Saint Pierre and Miquelon", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Georgia and the South Sandwich Islands", "Spain", "Sri Lanka", "Sudan", "Suriname", "Svalbard and Jan Mayen", "Swaziland", "Sweden", "Syrian Arab Republic", "Taiwan", "Tajikistan", "Tanzania, United Republic of", "Thailand", "Timor-Leste", "Togo", "Tokelau", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Turks and Caicos Islands", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United States Minor Outlying Islands", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela, Bolivarian Republic of", "Viet Nam", "Virgin Islands, British", "Virgin Islands, U.S.", "Wallis and Futuna", "Western Sahara", "Yemen", "Zambia", "Zimbabwe", "US","U.S", "USA", "U.S.A"]; 
        
        var state = ["Alaska", "Alabama", "Alaska", "Alabama", "Arkansas", "Arizona", "California", "Colorado", "Connecticut", "District of Columbia", "Delaware", "Florida", 
                     "Georgia", "Hawaii", "Iowa", "Idaho", "Illinois", "Indiana", "Kansas", "Kentucky", "Louisiana", "Massachusetts", "Maryland", "Maine", "Michigan", "Minnesota", "Missouri", 
                     "Mississippi", "Montana", "North Carolina", "North Dakota", "Nebraska", "New Hampshire", "New Jersey", "New Mexico", "Nevada", "New York", "Ohio", "Oklahoma", "Oregon", 
                     "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Virginia", "Vermont", "Washington", "Wisconsin", "West Virginia", 
                     "Wyoming"]; 
        var stateCode = ["AK", "AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "PR", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY", "AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "PR", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV"]; 
        var accountObj= component.get('v.account'); 
        if(accountObj!= null){
            var currentStatus = accountObj.Oracle_Integration_Status__c;
            var oracleCustNumber  = accountObj.Oracle_Customer_Number__c;
            var billingStreet = accountObj.BillingStreet; 
            var billingCity = accountObj.BillingCity; 
            var billingState = accountObj.BillingState; 
            var billingCountry = accountObj.BillingCountry; 
            var shippingStreet = accountObj.ShippingStreet; 
            var shippingCity = accountObj.ShippingCity; 
            var shippingState = accountObj.ShippingState; 
            var shippingCountry = accountObj.ShippingCountry; 
            var shippingPostalCode  =accountObj.ShippingPostalCode;
            var billingPostalCode  =accountObj.BillingPostalCode;
            
            var i; 
            var validBillingCountry = "N"; 
            var validShippingCountry = "N"; 
            
            var validBillingState = "N"; 
            var validShippingState = "N"; 
            
            
            var usBillingCustomer = "N" 
            var usShippingCustomer = "N" 
            
            if( billingCountry == "United States" || billingCountry == "US"|| billingCountry 
               == "U.S" || billingCountry == "USA" || billingCountry == "U.S.A"){ 
                usBillingCustomer = "Y"; 
            } 
            
            if( shippingCountry == "United States" || shippingCountry == "US"|| shippingCountry 
               == "U.S" || shippingCountry == "USA" || shippingCountry == "U.S.A"){ 
                usShippingCustomer = "Y"; 
            } 
            
            for (i = 0; i < country.length; i++) { 
                if (country[i] == billingCountry){ 
                    validBillingCountry = "Y"; 
                    break; 
                    
                } 
            } 
            for (i = 0; i < country.length; i++) { 
                
                if (country[i] == shippingCountry){ 
                    validShippingCountry = "Y"; 
                    break; 
                    
                } 
            } 
            for (i = 0; i < state.length; i++) { 
                if (state[i] == billingState){ 
                    validBillingState = "Y"; 
                    break; 
                } 
            } 
            if (validBillingState =="N"){ 
                for (i = 0; i < stateCode.length; i++) { 
                    if (stateCode[i] == billingState){ 
                        validBillingState = "Y"; 
                        break; 
                    } 
                } 
            } 
            for (i = 0; i < state.length; i++) { 
                if (state[i] == shippingState){ 
                    validShippingState = "Y"; 
                    break; 
                } 
            } 
            if (validShippingState == "N"){ 
                for (i = 0; i < stateCode.length; i++) { 
                    if (stateCode[i] == shippingState){ 
                        validShippingState = "Y"; 
                        break; 
                    } 
                } 
            } 
            console.log(currentStatus);
            
            //Condition for Checking the Deal Desk and System Admin profiles
            var profileAction = component.get('c.getProfileData');
            profileAction.setCallback(this, function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){                    
                    var hasAccess = response.getReturnValue();
                    if(hasAccess){
                     //  alert(shippingPostalCode+shippingCountry+shippingCity+shippingStreet+shippingState+billingState+billingStreet+billingCity+billingCountry+billingPostalCode);
                        if (shippingState=='' ||shippingState==null|| shippingState== undefined|| billingState==''||billingState==null|| billingState== undefined||billingStreet =='' ||billingStreet==null|| billingStreet== undefined|| billingCity ==''||billingCity==null|| billingCity== undefined|| billingCountry ==''||billingCountry==null|| billingCountry== undefined || shippingStreet =='' ||shippingStreet==null|| shippingStreet== undefined|| shippingCity ==''||shippingCity==null|| shippingCity== undefined||shippingCountry =='' ||shippingCountry==null|| shippingCountry== undefined|| shippingPostalCode==''||shippingPostalCode==null|| shippingPostalCode== undefined||billingPostalCode==''||billingPostalCode==null|| billingPostalCode== undefined){  
                            helper.openModel(component," Shipping/Billing address is incomplete. Cannot proceed!","Error"); 
                        } 
                        else if ((validBillingCountry =="N") || (validShippingCountry == "N" )){ 
                            helper.openModel(component,"Incorrect Billing or Shipping Country. Following are the valid Oracle Country list: " + country,"Error");
                        } 
                        else if (( usBillingCustomer == "Y") && (validBillingState == "N")){ 
                            helper.openModel(component,"Incorrect US Billing State. Please enter UPPER case state code or enter one of the state name listed below: " + state,"Error");
                        } 
                        else if ((usShippingCustomer == "Y") && (validShippingState == "N")){ 
                            helper.openModel(component,"Incorrect US Shipping State. Please enter UPPER case state code or enter one of the state name listed below: " + state,"Error");
                        } 
                        else if (currentStatus == "Pending" || currentStatus == "Error"|| currentStatus == '' || currentStatus == undefined || currentStatus ==null){ 
                            accountObj.Oracle_Integration_Status__c = "Requested"; 
                            component.set('v.account', accountObj);
                            helper.saveDetails(component, event, helper); 
                        } else if(!$A.util.isUndefinedOrNull(oracleCustNumber)){
                            helper.openModel(component,"Oracle number is already generated. Cannot proceed!","Error");
                        } else{ 
                            helper.openModel(component,"'Oracle Integration Status' is either 'Requested' or 'Completed'. Cannot proceed! ","Error");
                        } 
                    } else {
                        helper.openModel(component,"Only Deal Desk and System Admininstator users are Authorized to Access ","Error");
                    }
                }//end: if-state            
            });
            $A.enqueueAction(profileAction);
                       
        }
    },
    saveDetails : function(component, event, helper) {
        var action = component.get('c.saveDetails');
        var account = component.get('v.account');
        action.setParams({
            accountRecord: account
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                if(result == true){
                    helper.openModel(component,"This customer will be created in ORACLE in few minutes.","Success"); 
                    var modalClosed =  component.get("v.isOpen");
                    if(!modalClosed){
                        helper.navigateToDetailPage(account.Id);
                    }
                }
                else{
                    helper.openModel(component,"An unexpected error has occured, please cntact the Admin","Error");
                }
            } 
            else if(state === 'ERROR'){
                helper.openModel(component,"An unexpected error has occured, please cntact the Admin","Error");
            }
        });
        $A.enqueueAction(action);
    },
    navigateToDetailPage : function(accountId) {
        sforce.one.navigateToSObject(accountId,"detail"); 
    },
    openModel: function(component,message, title) {
        component.set("v.message",message);
        component.set("v.title",title)
        component.set("v.isOpen",true)
    },
    
});