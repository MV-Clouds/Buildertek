/* BT Lightning Component Controller.
 * Copyright 2016-2017, Builder Tek.
 * All rights reserved
 *
 * Created by 
 *
 * - Modifications:
 */

/* Lightning CLI rule */
/*global JQ$*/
({
    //showSpinner: this will call on aura waiting hendler 
    showSpinner: function (component, event, helper) {
        //var spinner = component.find("BTSpinner");
        //$A.util.addClass(spinner, 'slds-show');
        //$A.util.removeClass(spinner, 'slds-hide');
    },

    //hideSpinner: this will call on aura doneWaiting hendler
    hideSpinner: function (component, event, helper) {
        //var spinner = component.find("BTSpinner");
        //$A.util.addClass(spinner, 'slds-hide');
        //$A.util.removeClass(spinner, 'slds-show');
    },
    
    handlelocationchange: function (component, event, helper) {
    	//component.destroy();
    },
    
    handleDestroy: function (component, event, helper) {
    	
    },
    handleSaveSuccess: function (component, event, helper) {
    },
   
    initializeData: function (component, event, helper) {
    	var tableId, objectName, filterConditions, globalId, fieldSetName, GroupingColumns, editableColumns, isShowGroupingSummery, rowActoins, globalId = component.getGlobalId();
    	
    	tableId = component.get("v.TableId");
    	objectName = component.get("v.objectName");
        filterConditions = component.get("v.filterConditions");
        fieldSetName=component.get("v.fieldSetName");
        GroupingColumns = component.get("v.GroupingColumns");
        rowActoins = component.get("v.actions");
        editableColumns = component.get("v.editableColumnList");
        
        
        
    	helper.getGidDataRecords(component, event, helper, objectName, filterConditions, globalId, fieldSetName, GroupingColumns, editableColumns, rowActoins, function(){
	        if (document.getElementById('gridDiv_' + tableId) && component.get("v.ColumnModels")) {
	        	JQ$('#'+tableId+'_gridslectedIds').val("");
	        	component.initializeJQGridFormattter();
	            helper.createGrid(component, event, helper);
	            helper.initializeGrid(component, event, helper);
	        }
    	});
    	
    	/*
    	JQ$(document).click(function (e){
		    JQ$(".slds-is-open").each( function(){
		        if(JQ$(this).has(e.target).length === 0){
    		        JQ$(this).removeClass('slds-is-open');
		        }
		    });
       });
    	 */
    	 
    
       
       JQ$('.editOnclick, .deleteOnclick, .transfer_budget_amountOnClick, .btgridActions').die();
	   JQ$('.editOnclick, .deleteOnclick, .transfer_budget_amountOnClick, .btgridActions').live('click', function (e) {
		   e.preventDefault();
				var ids = [];
				ids.push(this.dataset.id);
				
				switch(true){
				
					case (JQ$(this).hasClass('btgridActions')):
						if(JQ$(this).hasClass('slds-is-open')) {
							JQ$(this).removeClass('slds-is-open');
						} else {
							JQ$(this).addClass('slds-is-open');
						}
						
						return false;
						break;
					//Delegate Action 
					case (JQ$(this).hasClass('deleteOnclick')):
						component.set("v.idsToDelete",ids);
						var globalId = component.getGlobalId();
						JQ$('[id="' + globalId + '_deleteConform"]').show();
						return false;
						break;
					case (JQ$(this).hasClass('editOnclick')):
						
						var editRecordEvent = $A.get("e.force:editRecord");
						editRecordEvent.setParams({
							 "recordId": this.dataset.id
						});
						editRecordEvent.fire();
						return false;
						break;
					case (JQ$(this).hasClass('transfer_budget_amountOnClick')):
						var budgetItemEvent = component.getEvent("budgetItemEvent");
						budgetItemEvent.setParams({"budgetitemid" : this.dataset.id, "action": "transfer_budget"});
	                	budgetItemEvent.fire();
	                	return false;
						break;
					default:
					return false;
					//default
				}
		});
		
		
	   JQ$('.reinviteVendor, .awardVendor, .rejectVendor, .cancelVendorRFQ, .acceptedVendorRFQ').die();
       JQ$('.reinviteVendor, .awardVendor, .rejectVendor, .cancelVendorRFQ, .acceptedVendorRFQ').live('click', function (rowId) {
            var statusUpdateEvent = component.getEvent("RFQToVendorStatusUpdateEvent");
            var ids = [];
            ids.push(this.dataset.id);
            switch(true){
                case (JQ$(this).hasClass('awardVendor')):
                	statusUpdateEvent.setParams({"id" : ids, "status": "Awarded"});
                	statusUpdateEvent.fire();
                	return false;
                	break;
            	case (JQ$(this).hasClass('cancelVendorRFQ')):
                	statusUpdateEvent.setParams({"id" : ids, "status": "Canceled"});
                	statusUpdateEvent.fire();
                	return false;
                	break;
            	case (JQ$(this).hasClass('acceptedVendorRFQ')):
                	statusUpdateEvent.setParams({"id" : ids, "status": "Accepted"});
                	statusUpdateEvent.fire();
                	return false;
                	break;
            	case (JQ$(this).hasClass('rejectVendor')):
                	statusUpdateEvent.setParams({"id" : ids, "status": "Rejected"});
                	statusUpdateEvent.fire();
                	return false;
                	break;
            	case (JQ$(this).hasClass('reinviteVendor')):
                	statusUpdateEvent.setParams({"id" : ids, "status": "Email Sent"});
                	statusUpdateEvent.fire();
                	return false;
                	break;
                default:
                return false;
				//default
            }
            return false;
       });
	   
	   JQ$('.newQuoteItem, .newProductItem, .editQuoteGroup').die();
	   JQ$('.newQuoteItem, .newProductItem, .editQuoteGroup').live('click', function (rowId) {
			var gpId = this.dataset.id;
			var editQuoteItemEvent = component.getEvent("editQuoteItemEvent");
			switch(true){
				case (JQ$(this).hasClass('newQuoteItem')):
					editQuoteItemEvent.setParams({"groupId" : gpId, "action": "NEW_ITEM"});
	                editQuoteItemEvent.fire();
	                return false;
					break;
				case (JQ$(this).hasClass('newProductItem')):
					editQuoteItemEvent.setParams({"groupId" : gpId, "action": "ADD_PRODUCTS"});
	                editQuoteItemEvent.fire();
	                return false;
					break;
				case (JQ$(this).hasClass('editQuoteGroup')):
					editQuoteItemEvent.setParams({"groupId" : gpId, "action": "EDIT_GROUP"});
	                editQuoteItemEvent.fire();
	                return false;
					break;
				default:
				return false;
				//default
			}
		});
	   
	   
    },
   
    // Create grid table and pager
    // and initialize grid details
    initialize: function (component, event, helper) {
        var tableId = component.get("v.TableId");
        if (document.getElementById('gridDiv_' + tableId) && component.get("v.ColumnModels")) {
        	JQ$('#'+tableId+'_gridslectedIds').val("");
        	component.initializeJQGridFormattter();
            helper.createGrid(component, event, helper);
            helper.initializeGrid(component, event, helper);
            
           
        }
    },
    
    getSelectedIds: function (component, event, helper) {
        var ids = JQ$("#"+component.get("v.TableId")).jqGrid("getGridParam", "selarrrow");
        if(ids.length > 0){
        	event.getParam('arguments').param1['ids'] = ids;
        } else {
        	event.getParam('arguments').param1['ids'] = -1;
        }	
    },
    
    // Initialize jqgrid formattre for different type of columns
    // linkFormatter - Clickable link fromatter
    // commonFormatter - General formatter to display blank or value
    // datetimeFormatter - Date time formatter
    // checkBoxFormatter - Checkbox formatter to display checkbox
    // numberToPercent - Convert number to percent
    initializeJQGridFormattter: function (component, event, helper) {
        JQ$.extend(JQ$.fn.fmatter, {
            commonFormatter: function (cellvalue, options, rowdata) {
                if (typeof cellvalue !== "undefined" && cellvalue !== null && cellvalue.trim() !== '') {
                    return cellvalue;
                } else {
                    return '';
                }
            },
            linkFormatter: function (cellvalue, options, rowdata) {
                var objFormatOptions, urlField, namespace, UiTheme;
                UiTheme = component.get("v.UiThemeDisplayed");

                if (typeof cellvalue !== "undefined" && cellvalue !== null && cellvalue.trim() !== '' && options.colModel.formatoptions !== null) {
                    objFormatOptions = options.colModel.formatoptions;
                    return helper.prepareDynamicLink(UiTheme, cellvalue, options, rowdata, objFormatOptions.urlField, objFormatOptions.addSlash, objFormatOptions.target);
                } else {
                    return '';
                }
            },
            datetimeFormatter: function (cellvalue, options, rowdata) {
                if (cellvalue !== null && cellvalue.trim() !== '') {
                    var parsedData, isoFormatValue, date = new Date(cellvalue.trim());
                    isoFormatValue = date.toISOString();
                    parsedData = JQ$.jgrid.parseDate("ISO8601Long", isoFormatValue, "m/d/Y h:i A");
                    return parsedData;
                } else {
                    return '';
                }
            },
            checkBoxFormatter: function (cellvalue, options, rowdata) {
                if (cellvalue !== null && cellvalue.trim() !== '' && cellvalue.trim() === 'true') {
                    return '<input type="checkbox" disabled="" checked="true" />';
                } else {
                    return '<input type="checkbox" disabled="" />';
                }
            },
            numberToPercent: function (cellvalue, options, rowdata) {
                if (cellvalue !== null && cellvalue !== undefined) {
                    return cellvalue + '%';
                } else {
                    return '0%';
                }
            },
            actionFormatter: function (cellvalue, options, rowdata) {
            	
            	var actionsToAllow = component.get("v.actions");
            	
            	
            	var actions = '<div>'
								+'<div class="btgridActions slds-dropdown-trigger slds-dropdown-trigger_click">'
									+'<button class="slds-button slds-button_icon slds-button_icon-border-filled slds-button_icon-x-small" aria-haspopup="true" title="Show More">'
										+'<svg class="slds-button__icon" aria-hidden="true">'
											+'<use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/resource/SLDS/assets/icons/utility-sprite/svg/symbols.svg#down" />'
										+'</svg>'
										+'<span class="slds-assistive-text">Show Actions</span>'
									+'</button>'
									+'<div class="slds-dropdown slds-dropdown_right">'
										+'<ul class="slds-dropdown__list" role="menu">';
											if(actionsToAllow.indexOf('Edit') != -1){
												actions = actions +'<li class="slds-dropdown__item editOnclick" role="presentation" title="Edit" data-id = "'+rowdata.Id+'">'
													+'<a href="javascript:void(0);" role="menuitemcheckbox" aria-checked="true" tabindex="0">'
														+'<span class="slds-truncate" title="Edit">Edit</span>'
													+'</a>'
												+'</li>';
											}
											
											if(actionsToAllow.indexOf('Delete') != -1){
												actions = actions+'<li class="slds-dropdown__item deleteOnclick" role="presentation" title="Delete" data-id = "'+rowdata.Id+'">'
													+'<a href="javascript:void(0);" role="menuitemcheckbox" aria-checked="false" tabindex="-1">'
														+'<span class="slds-truncate" title="Delete">Delete</span>'
													+'</a>'
												+'</li>';
											}
											
											if(actionsToAllow.indexOf('transfer_budget_amount') != -1){
												actions = actions+'<li class="slds-dropdown__item transfer_budget_amountOnClick" role="presentation" title="Transfer Budget Amount" data-id = "'+rowdata.Id+'">'
													+'<a href="javascript:void(0);" role="menuitemcheckbox" aria-checked="false" tabindex="-1">'
														+'<span class="slds-truncate" title="Transfer Budget Amount">Transfer Budget Amount</span>'
													+'</a>'
												+'</li>';
											}
										actions = actions +'</ul>'
									+'</div>'
								+'</div>'
							+'</div>';
            	
							/*   
							   JQ$('.editOnclick, .deleteOnclick, .transfer_budget_amountOnClick, .btgridActions').die();
							   JQ$('.editOnclick, .deleteOnclick, .transfer_budget_amountOnClick, .btgridActions').live('click', function (rowId) {
									var ids = [];
									ids.push(this.dataset.id);
									switch(true){
									
										case (JQ$(this).hasClass('btgridActions')):
											JQ$(this).addClass('slds-is-open');
											return false;
											break;
										//Delegate Action 
										case (JQ$(this).hasClass('deleteOnclick')):
											component.set("v.idsToDelete",ids);
											var globalId = component.getGlobalId();
											JQ$('[id="' + globalId + '_deleteConform"]').show();
											return false;
											break;
										case (JQ$(this).hasClass('editOnclick')):
											
											var editRecordEvent = $A.get("e.force:editRecord");
											editRecordEvent.setParams({
												 "recordId": this.dataset.id
											});
											editRecordEvent.fire();
											break;
										case (JQ$(this).hasClass('transfer_budget_amountOnClick')):
											var budgetItemEvent = component.getEvent("budgetItemEvent");
											budgetItemEvent.setParams({"budgetitemid" : this.dataset.id, "action": "transfer_budget"});
						                	budgetItemEvent.fire();
											break;
										default:
										//default
									}
								});
							   */
				return actions;
				
            },
            groupingSummeryFormatter: function (cellvalue, options, rowdata, action) {
                var GroupingSummaryFields, TableId, namespace, currentUser, groupIdPrefix, groupIdPrefixLength, data, i, j, l, item, objFormatOptions, assessmentId, isUserHaveAssessmentEditPermission, summary, completionDate, status, UiTheme, targetUrl, field;
                currentUser = component.get("v.currentUser");
                namespace = component.get("v.namespace");
                TableId = '#' + component.get("v.TableId");
                GroupingSummaryFields = component.get("v.GroupingSummaryFields");

                /*************** Start Grouping Header Customization ********************/
                if(component.get("v.showGroupingsummery")) {
                    //Set Target value at the grouping header in task manger
                    groupIdPrefix = options.gid + "ghead_";
                    groupIdPrefixLength = groupIdPrefix.length;
                    
                    // check wether options.rowId start with opts.gid + "ghead_" and integer
                    if (options.rowId.substr(0, groupIdPrefixLength) === groupIdPrefix && typeof action === "undefined") {
                        
                        // custom formating of the group header
                        // Get grid data
                        data = JQ$(this).jqGrid("getGridParam", "data");
                        objFormatOptions = options.colModel.formatoptions;
                        
                        for (i = 0, l = data.length; i < l; i += 1) {
                            item = data[i];
                            
                            if (item["buildertek__Vendor__c"] === cellvalue) {
                               cellvalue = item["buildertek__Vendor__r.Name"]
                               // TODO: DO this dinamicly, this are the summry fields, it should come from field set
                               var contactName = item["buildertek__Vendor__r.buildertek__Contact__r.Name"];
                               var vendorStatus = item["buildertek__Vendor__r.buildertek__Status__c"];
                               var quoteAmount = item["buildertek__Vendor__r.buildertek__Quote_Amount__c"];
                               var rfqStatus = item["buildertek__Vendor__r.buildertek__RFQ_Status__c"];
                               if(quoteAmount){
                            	   quoteAmount = quoteAmount.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
                               }
                               summary = '<sapn class="btgroupsummryTitle"><span class="btgroupsummry">'+cellvalue+'</span>';
                           	   summary += '&nbsp;<span class="btgroupsummry">(Contact: </span>'+contactName+' | <span class="btgroupsummry">Status: </span>'+vendorStatus+' <span class="btgroupsummry">| Quote Amonut: </span>$'+quoteAmount+'<span class="btgroupsummry">)</span>';
                               summary += '<span style="float:right">';
                               summary += '<div class="slds-button-group" role="group">';
                               
                               var sendEmailAction = '<span class="slds-badge slds-theme_info reinviteVendor pointer" data-id = "'+item.buildertek__Vendor__c+'">'
														+'<span class="slds-icon_container slds-icon-utility-moneybag slds-m-right_xx-small">'
															+'<svg class="slds-button__icon" aria-hidden="true"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/resource/SLDS/assets/icons/utility-sprite/svg/symbols.svg#email" /></svg>'
														+'</span>Send Email</span>';
                               
                           	   var awardAction = '<span class="slds-badge slds-theme_success awardVendor pointer" data-id = "'+item.buildertek__Vendor__c+'">'
														+'<span class="slds-icon_container slds-icon-utility-moneybag slds-m-right_xx-small">'
															+'<svg class="slds-button__icon" aria-hidden="true"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/resource/SLDS/assets/icons/utility-sprite/svg/symbols.svg#success" /></svg>'
														+'</span>Award</span>';
														
                       	   	   var rejectAction = '<span class="slds-badge slds-theme_error rejectVendor pointer" data-id = "'+item.buildertek__Vendor__c+'">'
														+'<span class="slds-icon_container slds-icon-utility-moneybag slds-m-right_xx-small">'
															+'<svg class="slds-button__icon" aria-hidden="true"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/resource/SLDS/assets/icons/utility-sprite/svg/symbols.svg#clear" /></svg>'
														+'</span>Reject</span>';
														
                       	   	   var cancelAction = '<span class="slds-badge slds-theme_error cancelVendorRFQ pointer" data-id = "'+item.buildertek__Vendor__c+'">'
														+'<span class="slds-icon_container slds-icon-utility-moneybag slds-m-right_xx-small">'
															+'<svg class="slds-button__icon" aria-hidden="true"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/resource/SLDS/assets/icons/utility-sprite/svg/symbols.svg#clear" /></svg>'
														+'</span>Cancel</span>';
														
                       	   	   var acceptedAction = '<span class="slds-badge slds-theme_success acceptedVendorRFQ pointer" data-id = "'+item.buildertek__Vendor__c+'">'
														+'<span class="slds-icon_container slds-icon-utility-moneybag slds-m-right_xx-small">'
															+'<svg class="slds-button__icon" aria-hidden="true"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/resource/SLDS/assets/icons/utility-sprite/svg/symbols.svg#success" /></svg>'
														+'</span>Accepted</span>';
							   
							   var acceptedDoneAction = '<span class="slds-badge slds-theme_success" data-id = "'+item.buildertek__Vendor__c+'">'
														+'<span class="slds-icon_container slds-icon-utility-moneybag slds-m-right_xx-small">'
															+'<svg class="slds-button__icon" aria-hidden="true"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/resource/SLDS/assets/icons/utility-sprite/svg/symbols.svg#success" /></svg>'
														+'</span>Accepted</span>';
							   
							   var rejectedDoneAction = '<span class="slds-badge slds-theme_error" data-id = "'+item.buildertek__Vendor__c+'">'
														+'<span class="slds-icon_container slds-icon-utility-moneybag slds-m-right_xx-small">'
															+'<svg class="slds-button__icon" aria-hidden="true"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/resource/SLDS/assets/icons/utility-sprite/svg/symbols.svg#clear" /></svg>'
														+'</span>Rejected</span>';
                               
                               
                               if(rfqStatus != 'Awarded' && rfqStatus != 'Accepted') {
                            	   if(vendorStatus == 'Rejected'){
                        			   summary += rejectedDoneAction;
                            	   } else {
                            		   summary += sendEmailAction + awardAction + rejectAction;
                            	   }
                               } else if(rfqStatus == 'Awarded' && vendorStatus == 'Awarded'){
                            	   summary += cancelAction + acceptedAction;
                               } else if(rfqStatus == 'Accepted' && vendorStatus == 'Accepted'){
                            	   summary += acceptedDoneAction;
                               }
                               
                               summary += '</div></span>';
                               summary += '</span>';
                               if (summary) {
                            	   
                            	   /*
                        	   	   JQ$('.reinviteVendor, .awardVendor, .rejectVendor, .cancelVendorRFQ, .acceptedVendorRFQ').die();
							       JQ$('.reinviteVendor, .awardVendor, .rejectVendor, .cancelVendorRFQ, .acceptedVendorRFQ').live('click', function (rowId) {
							            var statusUpdateEvent = component.getEvent("RFQToVendorStatusUpdateEvent");
							            var ids = [];
							            ids.push(this.dataset.id);
							            switch(true){
							                case (JQ$(this).hasClass('awardVendor')):
							                	statusUpdateEvent.setParams({"id" : ids, "status": "Awarded"});
							                	statusUpdateEvent.fire();
							                	break;
							            	case (JQ$(this).hasClass('cancelVendorRFQ')):
							                	statusUpdateEvent.setParams({"id" : ids, "status": "Canceled"});
							                	statusUpdateEvent.fire();
							                	break;
							            	case (JQ$(this).hasClass('acceptedVendorRFQ')):
							                	statusUpdateEvent.setParams({"id" : ids, "status": "Accepted"});
							                	statusUpdateEvent.fire();
							                	break;
							            	case (JQ$(this).hasClass('rejectVendor')):
							                	statusUpdateEvent.setParams({"id" : ids, "status": "Rejected"});
							                	statusUpdateEvent.fire();
							                	break;
							            	case (JQ$(this).hasClass('reinviteVendor')):
							                	statusUpdateEvent.setParams({"id" : ids, "status": "Email Sent"});
							                	statusUpdateEvent.fire();
							                	break;
							                default:
											//default
							            }
							            return false;
							       });
                            	   	*/
		                            return '<span>' + JQ$('<div/>').html(decodeURI(summary)).html() + '</span>';
		                        } else {
		                            return '<span>' + JQ$('<div/>').html(decodeURI(cellvalue)).html() + '</span>';
		                        }
                            } else if (item["buildertek__Grouping__r.Name"] === cellvalue) {
                            	
                        	   summary = '<sapn class="btgroupsummryTitle"><span class="btgroupsummry">'+cellvalue+'</span>';
                               summary += '<span style="float:right">';
                               summary += '<div class="slds-button-group" role="group">';
                               
                               var newItem = '<span class="slds-badge slds-theme_info reinviteVendor pointer newQuoteItem" title="Add New Product" data-id = "'+item.buildertek__Grouping__c+'">'
														+'<span class="slds-icon_container slds-icon-utility-moneybag slds-m-right_xx-small">'
															+'<svg class="slds-button__icon" aria-hidden="true"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/resource/SLDS/assets/icons/utility-sprite/svg/symbols.svg#add" /></svg>'
														+'</span>Add New Product</span>';
                               
                               
                               var addproduct = '<span class="slds-badge slds-theme_info reinviteVendor pointer newProductItem" title="Add Product" data-id = "'+item.buildertek__Grouping__c+'">'
														+'<span class="slds-icon_container slds-icon-utility-moneybag slds-m-right_xx-small">'
															+'<svg class="slds-button__icon" aria-hidden="true"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/resource/SLDS/assets/icons/utility-sprite/svg/symbols.svg#table" /></svg>'
														+'</span>Add Product</span>';
							   
							   var editGroup = '<span class="slds-badge slds-theme_info reinviteVendor pointer editQuoteGroup" title="Edit Group" data-id = "'+item.buildertek__Grouping__c+'">'
														+'<span class="slds-icon_container slds-icon-utility-moneybag slds-m-right_xx-small">'
															+'<svg class="slds-button__icon" aria-hidden="true"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="/resource/SLDS/assets/icons/utility-sprite/svg/symbols.svg#edit" /></svg>'
														+'</span>Edit Group</span>';
							   
							 
                           	   summary += newItem + addproduct + editGroup;
                               summary += '</div></span>';
                               summary += '</span>';
                               
                               /*
                               
                               JQ$('.newQuoteItem, .newProductItem, .editQuoteGroup').die();
							   JQ$('.newQuoteItem, .newProductItem, .editQuoteGroup').live('click', function (rowId) {
									var gpId = this.dataset.id;
									var editQuoteItemEvent = component.getEvent("editQuoteItemEvent");
									switch(true){
										case (JQ$(this).hasClass('newQuoteItem')):
											editQuoteItemEvent.setParams({"groupId" : gpId, "action": "NEW_ITEM"});
							                editQuoteItemEvent.fire();
											break;
										case (JQ$(this).hasClass('newProductItem')):
											editQuoteItemEvent.setParams({"groupId" : gpId, "action": "ADD_PRODUCTS"});
							                editQuoteItemEvent.fire();
											break;
										case (JQ$(this).hasClass('editQuoteGroup')):
											editQuoteItemEvent.setParams({"groupId" : gpId, "action": "EDIT_GROUP"});
							                editQuoteItemEvent.fire();
											break;
										default:
										//default
									}
								});
								
								*/
                               return '<span>' + JQ$('<div/>').html(decodeURI(summary)).html() + '</span>';
                            }
                            
                        }
                        return '<span>' + JQ$('<div/>').html(decodeURI(cellvalue)).html() + '</span>';
                    } else {
                    	this.linkFormatter(cellvalue, options, rowdata);
                    }
                }
            }
        });
    },

    //Expand All
    expandAll: function (component, event, helper) {
        var gridTableId, $grid, idPrefix, trspans, groups, index, tableID = component.get("v.TableId");
        gridTableId = '#' + tableID;
        $grid = JQ$(gridTableId);
        idPrefix = $grid[0].id + "ghead_0_";
        groups = $grid[0].p.groupingView.groups;
        if ($grid[0].p.grouping) {
            for (index = 0; index < groups.length; index += 1) {
                trspans = JQ$("#" + idPrefix + index + " span.tree-wrap." + $grid[0].p.groupingView.plusicon);
                if (trspans.length > 0) {
                    $grid.jqGrid('groupingToggle', idPrefix + index, '#'+idPrefix + index);
                }
            }
        }
    },

    //collapse All
    collapseAll: function (component, event, helper) {
        var gridTableId, $grid, idPrefix, trspans, groups, index, tableID = component.get("v.TableId");
        gridTableId = '#' + tableID;
        $grid = JQ$(gridTableId);
        idPrefix = $grid[0].id + "ghead_0_";
        groups = $grid[0].p.groupingView.groups;
        if ($grid[0].p.grouping) {
            for (index = 0; index < groups.length; index += 1) {
                trspans = JQ$("#" + idPrefix + index + " span.tree-wrap." + $grid[0].p.groupingView.minusicon);
                if (trspans.length > 0) {
                    $grid.jqGrid('groupingToggle', idPrefix + index, '#'+idPrefix + index);
                }
            }
        }
    },
    
    deleteRecord: function(component, event, helper){
    	var globalId = component.getGlobalId();
		JQ$('[id="' + globalId + '_deleteConform"]').hide();
		if(component.get("v.idsToDelete").length > 0){
			$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
			helper.deleteSelectedRecord(component, event, helper, component.get("v.objectName"), component.get("v.idsToDelete"));
			component.set("v.idsToDelete","[]")
    	} else {
    		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
    		helper.deleteSelectedRecord(component, event, helper, component.get("v.objectName"), event.getParam('arguments').param1);
    	}
	},
	
	hideDeleteConform:function(component){
		var globalId = component.getGlobalId();
		JQ$('[id="' + globalId + '_deleteConform"]').hide();
	},
	addSelectedRecords: function(component, event, helper){
		var ids = JQ$("#"+component.get("v.TableId")).jqGrid("getGridParam", "selarrrow");
		if(ids.length <= 0 ){
			var toastEvent = $A.get("e.force:showToast");
	        toastEvent.setParams({
	            "title": "",
	            "message": "Please Select Record",
	            "type": "Error"
	        });
	        toastEvent.fire();
        } else {
        	helper.addSelectedRecordToRHS(component, event, helper, ids);
    	}
	},
	
	deleteRHS: function(component, event, helper){
		var ids = JQ$("#"+component.get("v.TableId")).jqGrid("getGridParam", "selarrrow");
		if(ids.length <= 0){
			var toastEvent = $A.get("e.force:showToast");
	        toastEvent.setParams({
	            "title": "",
	            "message": "Please Select Record",
	            "type": "Error"
	        });
	        toastEvent.fire();
        } else {
        
        	helper.deleteSelectedRecordFromRHS(component, event, helper, ids);
        }
	},
	
	save: function(component, event, helper){
		var gridTable = JQ$("#"+component.get("v.TableId")), ids = gridTable.jqGrid('getDataIDs'), i, l = ids.length;
	    for (i = 0; i < l; i++) {
	        gridTable.jqGrid('saveRow', ids[i], true);
	    }
	}

})();