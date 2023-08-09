public with sharing class GrandChildWrapper{
	public String responseTypeName;
	public String selectedResponsetypeValue;
	public List<selectionChoices> selectionChoices;
	public class selectionChoices{
		public string ChoiceText;
		public string Question;
		public List<GrandChildOfGrandChildWrapper> children;

	}
}