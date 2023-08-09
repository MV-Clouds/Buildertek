public with sharing class CheckInTriggerHandler{
	public static Boolean blnSkipTrigger = false;
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	public CheckInTriggerHandler(boolean isExecuting, integer size){
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	public void OnBeforeInsert(buildertek__Check_In__c[] newCheckIns){
	}

	public void OnAfterInsert(buildertek__Check_In__c[] newCheckIns, Map<Id, buildertek__Check_In__c> newCheckInsMap){
		Set<Id> checkInIds = new Set<Id>();
		for (buildertek__Check_In__c checkIn : newCheckIns){
			if (checkIn.buildertek__Project__c != null){
				checkInIds.add(checkIn.Id);
			}
		}
		FutureMethodCallOut_ForWeatherCategory(checkInIds);
	}

	public void OnBeforeUpdate(buildertek__Check_In__c[] oldCheckIns, buildertek__Check_In__c[] newCheckIns, Map<Id, buildertek__Check_In__c> newCheckInsMap, Map<Id, buildertek__Check_In__c> oldCheckInsMap){
	}

	public void OnAfterUpdate(buildertek__Check_In__c[] oldCheckIns, buildertek__Check_In__c[] newCheckIns, Map<Id, buildertek__Check_In__c> newCheckInsMap, Map<Id, buildertek__Check_In__c> oldCheckInsMap){
	}

	public void OnBeforeDelete(buildertek__Check_In__c[] oldCheckIns, Map<Id, buildertek__Check_In__c> oldCheckInsMap){
	}

	public void OnAfterDelete(buildertek__Check_In__c[] oldCheckIns){
	}

	@future(CallOut = true)
	private static void FutureMethodCallOut_ForWeatherCategory(Set<Id> checkInIds){
		String requestUrl = Label.BT_Weather_API_URL; 
		String checkInId = '';
		String weatherCondition = '';
		requestUrl += 'data/2.5/weather?';
		List<buildertek__Check_In__c> checkInList = [Select Id, Name, buildertek__Project__r.buildertek__Longitude__c, buildertek__Project__r.buildertek__Latitude__c
		                                             FROM buildertek__Check_In__c
		                                             WHERE Id In :checkInIds];
		for (buildertek__Check_In__c checkIn : checkInList){
			checkInId = checkIn.Id;
			if (checkIn.buildertek__Project__r.buildertek__Latitude__c != null && checkIn.buildertek__Project__r.buildertek__Longitude__c != null){
				requestUrl += 'lat=' + checkIn.buildertek__Project__r.buildertek__Latitude__c;
				requestUrl += '&lon=' + checkIn.buildertek__Project__r.buildertek__Longitude__c;
				requestUrl += '&appid=' + Label.BT_Weather_API_Access_Token;
				Http http = new Http();
				HttpRequest request = new HttpRequest();
				request.setEndpoint(requestUrl);
				request.setMethod('GET');
				HttpResponse response = http.send(request);
				if (response.getStatus() == 'OK' && response.getStatusCode() == 200){
					WeatherWrapper weatherWrapperClass = (WeatherWrapper)JSON.deserialize(response.getBody(), WeatherWrapper.class);
					for (Weather weatherWrapper : weatherWrapperClass.weather){
						weatherCondition = weatherWrapper.main;
					}
					checkIn.Id = checkInId;
					checkIn.buildertek__Weather__c = weatherCondition;
				}
			}
		}
		CheckInTriggerHandler.blnSkipTrigger = true;
		update checkInList;
		CheckInTriggerHandler.blnSkipTrigger = false;
	}

	public class WeatherWrapper{
		public List<Weather> weather{ get; set; }
	}

	public class Weather{
		public String main{ get; set; }
	}
}