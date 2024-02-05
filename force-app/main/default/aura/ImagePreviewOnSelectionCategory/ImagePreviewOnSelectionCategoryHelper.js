({
    initializePagination: function(component) {
        var categoryList = component.get("v.categoryList");
        var categoriesPerPage = 6; // Set the number of categories to display per page

        // Initialize current page and calculate total pages
        component.set("v.currentPage", 1);
        component.set("v.totalPages", Math.ceil(categoryList.length / categoriesPerPage));

        // Display the first set of categories
        this.updateDisplayedCategories(component);
    },

    updateDisplayedCategories: function(component,event,helper) {
        var categoryList = component.get("v.categoryList");
        var currentPage = component.get("v.currentPage");
        var categoriesPerPage = 6; // Set the number of categories to display per page

        // Calculate the start and end index for the current page
        var startIndex = (currentPage - 1) * categoriesPerPage;
        var endIndex = startIndex + categoriesPerPage;

        // Slice the categoryList to get the categories for the current page
        var displayedCategories = categoryList.slice(startIndex, endIndex);

        component.set("v.displayedCategories", displayedCategories);
        this.showHideButtons(component);

    },

    previousPageNew: function(component,event,helper) {
        var currentPage = component.get("v.currentPage");

        // Ensure the current page is not the first page
        if (currentPage > 1) {
            component.set("v.currentPage", currentPage - 1);
            this.updateDisplayedCategories(component);
        }
        this.showHideButtons(component);

    },

    nextPageNew: function(component,event,helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = component.get("v.totalPages");

        // Ensure the current page is not the last page
        if (currentPage < totalPages) {
            component.set("v.currentPage", currentPage + 1);
            this.updateDisplayedCategories(component);
        }
        this.showHideButtons(component);

    },
    showHideButtons: function(component,event,helper) {
        var currentPage = component.get("v.currentPage");
        var totalPages = component.get("v.totalPages");
        console.log('currentPage' ,currentPage);
        console.log('totalPages',totalPages);

        // Determine whether to show/hide previous and next buttons
        component.set("v.showPreviousButton", currentPage > 1);
        component.set("v.showNextButton", currentPage < totalPages);
    }
})