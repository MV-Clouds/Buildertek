public with sharing class ParentWrapper{
	public String responseTypeName;
	public String selectedResponsetypeValue;
	public List<selectionChoices> selectionChoices;
	public class selectionChoices{
		public string ChoiceText;
		public string Question;
		public List<ChildWrapper> children;
	}
}