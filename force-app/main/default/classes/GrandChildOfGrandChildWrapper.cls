public with sharing class GrandChildOfGrandChildWrapper{
	public String responseTypeName;
	public String selectedResponsetypeValue;
	public List<selectionChoices> selectionChoices;

	public class selectionChoices{
		@AuraEnabled
		public String ChoiceText{ get; set; }

		@AuraEnabled
		public String Question{ get; set; }
	}
}