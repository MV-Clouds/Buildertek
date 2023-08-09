public with sharing class ChildWrapper{
	public String responseTypeName;
	public String selectedResponsetypeValue;
	public List<selectionChoices> selectionChoices;
	public class selectionChoices{
		public string ChoiceText;
		public string Question;
		public List<GrandChildWrapper> children;
	}
}