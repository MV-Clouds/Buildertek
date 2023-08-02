public with sharing class SelectionPrintPDF{
	public String recordId{ get; set; }

	public String selectionName{ get; set; }

	public Integer recCount{ get; set; }

	public List<buildertek__Question__c> questions{ get; set; }

	public List<QuestionWrapper> questionsWrapper{ get; set; }

	public Set<String> answerChoices{ get; set; }

	public SelectionPrintPDF(){
		recordId = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
		answerChoices = new Set<String>();
		questionsWrapper = new List<QuestionWrapper>();
		AttributeWrapper a = new AttributeWrapper();
		List<AttributeWrapper> aList = new List<AttributeWrapper>();
		QuestionWrapper w = new QuestionWrapper();
		if (String.isNotBlank(recordId)){
			questions = [Select Id, Name, buildertek__Question_Group__r.Name, buildertek__Image_Id__c, buildertek__Additional_Cost__c, buildertek__Question_HTML__c, (Select Id, Name, buildertek__Text_Value__c
			                                                                                                                                                          FROM buildertek__Answer_Choices__r)
			             FROM buildertek__Question__c
			             WHERE buildertek__Question_Group__c = :recordId];
			if (questions.size() > 0){
				selectionName = questions[0].buildertek__Question_Group__r.Name;
				for (buildertek__Question__c question : questions){
					w = new QuestionWrapper();
					aList = new List<AttributeWrapper>();
					w.name = question.Name;
					w.imgId = question.buildertek__Image_Id__c;
					w.cost = Decimal.valueOf(question.buildertek__Additional_Cost__c!= null ? question.buildertek__Additional_Cost__c : '0');
					for (buildertek__Answer_Choice__c answerChoice : question.buildertek__Answer_Choices__r){
						if (!answerChoices.contains(answerChoice.Name) && answerChoice.buildertek__Text_Value__c != null && answerChoice.buildertek__Text_Value__c != ''){
							a = new AttributeWrapper();
							answerChoices.add(answerChoice.Name);
							a.name = answerChoice.Name;
							a.value = answerChoice.buildertek__Text_Value__c;
							aList.add(a);
							w.attributeWrapper = aList;
						}
					}
					questionsWrapper.add(w);
				}
			}
		}
	}

	public class QuestionWrapper{
		public String name{ get; set; }

		public Decimal cost{ get; set; }

		public String imgId{ get; set; }

		public List<AttributeWrapper> attributeWrapper{ get; set; }
	}

	public class AttributeWrapper{
		public String name{ get; set; }

		public String value{ get; set; }
	}
}