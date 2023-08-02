/* 
 */

//Define Appurin namespace to hold Appurin lightning instance
var ForceUI = {};
var SLDSPath = '';
Appurin.namespace('Appurin.lightning');

(function () {
	"use strict";
	
	Appurin.lightning.setSLDSPath = function (path) {
		SLDSPath = path;
	};
	
	Appurin.lightning.back = function (refresh) {
		if (typeof sforce !== 'undefined') {
			sforce.one.back(refresh);
		}
	};
	
	Appurin.lightning.navigateToURL = function (url, isRedirect) {
		if (typeof sforce !== 'undefined') {
			sforce.one.navigateToURL(url, isRedirect);
		} else{
			window.open(url);
		}
	};
	
	Appurin.lightning.isLightningExperience = function () {
		if (typeof sforce !== 'undefined') {
			return (ForceUI.UserUITheme === 'Theme4d');
		} else {
			return false;
		}
	};
    
	Appurin.lightning.setUITheme = function (theme) {
		ForceUI.UserUITheme = theme;
	};
	
	Appurin.lightning.createTabPanel = function (tabPaneId){
		var tabPanelContainer = j$("div[id$='"+tabPaneId+"']"); 
		if(!tabPanelContainer){
			return;
		}
		tabPanelContainer.addClass('slds-tabs_default');
		tabPanelContainer.find("ul.apTabPanelNavigation").addClass('slds-tabs_default__nav');
		tabPanelContainer.find("li.apTabItem").addClass('slds-tabs__item').addClass('slds-text-heading--label');
		tabPanelContainer.find("li.apTabItem").addClass('slds-tabs__item').addClass('slds-text-heading--label').find("a.apTabItemLink").addClass('slds-tabs_default__link');
		tabPanelContainer.find("div.apTabContent").addClass('slds-tabs__content');
	}
          
	Appurin.lightning.switchTab = function (element){
		var tabPanel = j$("a[id$='"+element.id+"']").parent().parent().parent();
		tabPanel.find("div.slds-show").addClass('slds-hide').removeClass('slds-show');
		tabPanel.find("div[id$='"+element.id.split('__')[0]+"']").removeClass('slds-hide').addClass('slds-show');
		tabPanel.find("li.slds-active").removeClass('slds-active');
		tabPanel.find("a[id$='"+element.id+"']").parent().addClass('slds-active');
    }
    
	Appurin.lightning.createPageHeader = function (pageHeaderId){
		var pageHeaderContainer = j$("div[id$='"+pageHeaderId+"']"); 
		if(!pageHeaderContainer){
			return;
		}
		pageHeaderContainer.addClass('slds-page-header');
		var pageHeaderMediaDiv = pageHeaderContainer.find("div.apPageHeaderMedia");
		pageHeaderMediaDiv.addClass('slds-media').addClass('slds-media--center');
		pageHeaderMediaDiv.find("div.apPageHeaderMediaFigure").addClass('slds-media__figure');
		var pageHeaderMediaBody = pageHeaderMediaDiv.find("div.apPageHeaderMediaBody");
		pageHeaderMediaBody.addClass('slds-media__body');
		pageHeaderMediaBody.find("div.apPageHeaderTitle").addClass('slds-page-header__title').addClass('slds-truncate').addClass('slds-align-middle');
		pageHeaderMediaBody.find("div.apPageHeaderInfo").addClass('slds-text-body--small').addClass('page-header__info');
		pageHeaderMediaDiv.find("div.apPageHeaderMediaButtons").find("input[type=submit]").addClass('slds-button').addClass('slds-button--brand');
    }
	
	Appurin.lightning.createModalPopup = function (options){
		var modalPopupId = options.modalPopupId;
		var isAlertPrompt = options.isAlertPrompt;
        var modelPopup = j$("div[id$='"+modalPopupId+"']").addClass('slds').find("div.apModal"); 
		modelPopup.addClass('slds-modal').addClass('slds-fade-in-open');
		if(isAlertPrompt){
			modelPopup.addClass('slds-modal--prompt');
		} else{
		    modelPopup.removeClass('slds-modal--prompt');
		}
		var modalPopupContainer = modelPopup.find("div.apModalContainer").addClass('slds-modal__container')
		if(isAlertPrompt){
			modelPopup.find("div.apModalContainer").addClass('slds-modal--prompt');
		} else{
		    modelPopup.find("div.apModalContainer").removeClass('slds-modal--prompt');
		}
		if(isAlertPrompt){
			modalPopupContainer.find("div.apModalHeader").addClass('slds-theme--info').addClass('slds-theme--alert-texture');
		} else{
		    modalPopupContainer.find("div.apModalHeader").removeClass('slds-theme--info').removeClass('slds-theme--alert-texture');
		}
		modalPopupContainer.find("div.apModalHeader").addClass('slds-modal__header').find("h2.apModalHeading").addClass('slds-text-heading--medium');
		modalPopupContainer.find("div.apModalContent").addClass('slds-modal__content').addClass('slds-p-around--medium').find("div.apNotifyContainer").addClass('slds-notify_container');
		modalPopupContainer.find("div.apModalFooter").addClass('slds-modal__footer').find("button").addClass('slds-button').css('display', 'none');
		if(isAlertPrompt){
			modalPopupContainer.find("div.apModalFooter").addClass('slds-theme--default');
		} else{
		    modalPopupContainer.find("div.apModalFooter").removeClass('slds-theme--default');
		}
	}
	
	Appurin.lightning.showModalPopup = function (options){
		var modalPopupId = options.modalPopupId;
		j$("div[id$='"+modalPopupId+"']").css('display', 'block').find("button").css('display', 'inline-block');
	}
	
	Appurin.lightning.hideModalPopup = function (options){
		var modalPopupId = options.modalPopupId;
		j$("div[id$='"+modalPopupId+"']").css('display', 'none');
	}
	
	Appurin.lightning.showAlertPrompt = function (options){
		var modalPopupId = options.modalPopupId;
		var messageType = options.messageType;
		var title = options.title;
		var message = options.message;
		var buttonLabel = options.buttonLabel;
		var isRedirect = options.isRedirect;
		var modelPopup = j$("div[id$='"+modalPopupId+"']");
		Appurin.lightning.createModalPopup({'modalPopupId': modalPopupId, isAlertPrompt : true});
		j$("div[id$='"+modalPopupId+"']").css('display', 'block');
		j$("h2[id$='"+modalPopupId+"Header']").html(title);
		j$("h2[id$='"+modalPopupId+"Message']").html(message);
		var modalPopupHeader = modelPopup.find("div.apModalHeader").removeClass('slds-theme--error').removeClass('slds-theme--info').removeClass('slds-theme--warning').removeClass('slds-theme--success');
		modalPopupHeader.addClass('slds-theme--'+messageType.toLowerCase());
		modelPopup.find("div.apModalFooter").find("button").removeClass('slds-button--brand').addClass('slds-button--neutral');
		j$("button[id$='"+modalPopupId+"CloseButton']").css('display', 'none');
		j$("button[id$='"+modalPopupId+"OkButton']").css('display', 'inline-block');
		if(buttonLabel != null && buttonLabel != ''){
			j$("button[id$='"+modalPopupId+"OkButton']").html(buttonLabel);
		}
		if(!isRedirect){
			j$("button[id$='"+modalPopupId+"OkButton']").off("click").click(function() {
				Appurin.lightning.hideModalPopup({'modalPopupId' : modalPopupId});
				return false;
			});
		} else{ 
			j$("button[id$='"+modalPopupId+"OkButton']").off("click").click(function() {
				cancel();
			});
		}
		return false;
	}
	
	Appurin.lightning.showConfirmPrompt = function(options){
		var messageType = options.messageType;
		var modalPopupId = options.modalPopupId;
		var title = options.title;
		var message = options.message;
		var agreeButton = options.agreeButtonLabel;
		var discardButton =options.discardButtonLabel;
		var agreeFunction = options.agreeFunction;
		var messageType = "info";
		var modelPopup = j$("div[id$='"+modalPopupId+"']");
		Appurin.lightning.createModalPopup({'modalPopupId': modalPopupId, isAlertPrompt : false});
		j$("div[id$='"+modalPopupId+"']").css('display', 'block');
		j$("h2[id$='"+modalPopupId+"Header']").html(title);
		j$("h2[id$='"+modalPopupId+"Message']").html(message);
		var modalPopupHeader = modelPopup.find("div.apModalHeader").removeClass('slds-theme--error').removeClass('slds-theme--info').removeClass('slds-theme--warning').removeClass('slds-theme--success');
		modelPopup.find("div.apModalFooter").find("button").removeClass('slds-button--brand').addClass('slds-button--neutral').css('display', 'inline-block');
		if(agreeButton != null && agreeButton != ''){
			j$("button[id$='"+modalPopupId+"OkButton']").html(agreeButton);
		}
		if(discardButton != null && discardButton != ''){
			j$("button[id$='"+modalPopupId+"CloseButton']").html(discardButton);
		}
		j$("button[id$='"+modalPopupId+"OkButton']").addClass('slds-button--brand').off("click").click(agreeFunction);
		j$("button[id$='"+modalPopupId+"CloseButton']").off("click").click(function(){
			Appurin.lightning.hideModalPopup({'modalPopupId' : modalPopupId});
			return false;
		});
	}
	
	Appurin.lightning.createLightningPageMessage = function (options){
		
		var classicPageMessageId = options.classicPageMessageId;
		var lightningPageMessageId = options.lightningPageMessageId;
		var severity = options.severity;
		var icon = (severity == 'error' ? 'ban' : severity);
		var strength = options.strength;
		var summary = options.summary;
		
		if(classicPageMessageId != null){
			var calssicPageMessageElement = j$("span[id$='"+classicPageMessageId+"']");
			var calssicMessageDiv = calssicPageMessageElement.find("div.message");
			if(calssicMessageDiv.attr('class') == undefined){
				return;
			}
			var calssicMessageTextDiv = calssicMessageDiv.find("div.messageText");
			calssicMessageTextDiv.find("span").remove();
			var calssicMessageClass = calssicMessageDiv.attr('class').split(' ')[1];
			severity = calssicMessageClass.substring(0, calssicMessageClass.length-2);
			icon = (severity == 'error' ? 'ban' : severity);
			var messageIcon = "<svg class='slds-icon slds-icon--x-small slds-m-right--x-small'><use xmlns:xlink='http://www.w3.org/1999/xlink' xlink:href='"+SLDSPath+"/assets/icons/utility-sprite/svg/symbols.svg#"+icon+"'></use></svg>";
			strength = calssicMessageClass.substring(calssicMessageClass.length-1, calssicMessageClass.length);
			summary = calssicMessageTextDiv.html();
			if(calssicPageMessageElement != undefined){
				calssicPageMessageElement.html('').append(j$("<div class='slds apLightningNotify'/>").append(j$("<div class='slds-notify slds-notify--alert slds-theme--"+severity+" slds-theme--alert-texture'></div>").html(messageIcon+summary)));
			}
		} else{
			var messageIcon = "<svg class='slds-icon slds-icon--x-small slds-m-right--x-small'><use xmlns:xlink='http://www.w3.org/1999/xlink' xlink:href='"+SLDSPath+"/assets/icons/utility-sprite/svg/symbols.svg#"+icon+"'></use></svg>";
			j$("div[id='"+lightningPageMessageId+"']").html('').addClass('slds').addClass('apLightningNotify').append(j$("<div class='slds-notify slds-notify--alert slds-theme--"+severity+" slds-theme--alert-texture'></div>").html(messageIcon+summary));
		}
	}
	
	Appurin.lightning.createLightningSection = function (sectionId){
		if(twistyLightningSectionStatus[sectionId] != undefined){
			if(twistyLightningSectionStatus[sectionId]){
				j$("div[id='"+sectionId+"']").addClass('slds-is-open');    
			} else{
				j$("div[id='"+sectionId+"']").removeClass('slds-is-open');
			}
		}
		j$("div[id='"+sectionId+"']").find("div.slds-section__title-action").off('click').on("click", function (){
			if(j$("div[id='"+sectionId+"']").hasClass('slds-is-open')){
				j$("div[id='"+sectionId+"']").removeClass('slds-is-open');
				twistyLightningSectionStatus[sectionId] = false;
			} else{
				j$("div[id='"+sectionId+"']").addClass('slds-is-open');
				twistyLightningSectionStatus[sectionId] = true;
			}
		});
	}
	
	Appurin.lightning.showLightningMenu = function(lightningMenu){
		j$(lightningMenu).parent().addClass("slds-is-open");
	}
	
	Appurin.lightning.hideLightningMenu = function(lightningMenu){
		j$(lightningMenu).parent().parent().parent().removeClass("slds-is-open");
	}
	
}());