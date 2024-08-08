({
    obj : {},
    helperMethod: function () {

    },

    reorderSubsection: function(A, B){
        
        // Step 1: Create a mapping from values in B to objects in A
        let valueToObjectMap = new Map(A.map(obj => [obj.Name, obj]));
        
        // Step 2: Filter A to keep objects that have Ids listed in B and sort them
        let orderedFromB = B
            .filter(value => valueToObjectMap.has(value)) // Filter out values not in A
            .map(value => valueToObjectMap.get(value)); // Map values to objects
        
        // Step 3: Find objects in A that are not in B and append them
        let notInB = A.filter(obj => !B.includes(obj.Name));
        
        // Step 4: Combine the sorted objects with the remaining objects
        A = [...orderedFromB, ...notInB];
        
        return A;        
    },

    showToast: function (component, event, helper, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
})