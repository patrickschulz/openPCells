// get all the elements you'll need from your HTML
const input    = document.querySelector(".search-bar");
const results  = document.querySelector(".search-results");
const template = document.querySelector(".result");

// whenever the user types in the search input, look for a apiref by name
input.addEventListener("input", searchByAPIRefName);

function filterBySearch(array, searchTerm) {
    if (!searchTerm || searchTerm.trim() === '') {
        return array;
    }

    const lowerSearch = searchTerm.toLowerCase();

    const results = array.filter(entry => {
        const searchableText = [
            entry.module,
            entry.funcname,
            entry.description
        ].join(' ').toLowerCase();

        return searchableText.includes(lowerSearch);
    }).map(entry => {
        // Assign priority based on which field matches and position
        let priority;
        let startsWithMatch = false;

        const funcnameLower = entry.funcname.toLowerCase();
        const moduleLower = entry.module.toLowerCase();

        if (funcnameLower.includes(lowerSearch)) {
            priority = 1;
            startsWithMatch = funcnameLower.startsWith(lowerSearch);
        } else if (moduleLower.includes(lowerSearch)) {
            priority = 2;
            startsWithMatch = moduleLower.startsWith(lowerSearch);
        } else {
            priority = 3;
            startsWithMatch = false;
        }

        return { entry, priority, startsWithMatch };
    });

    // Sort by priority (1 = funcname, 2 = module, 3 = description)
    // Within each priority, prefer matches at the beginning
    results.sort((a, b) => {
        if (a.priority !== b.priority) {
            return a.priority - b.priority;
        }
        // Within same priority, prefer beginning matches
        return b.startsWithMatch - a.startsWithMatch;
    });

    // Return just the entries without priority
    return results.map(result => result.entry);
}

function searchByAPIRefName(inputEvent)
{
    const searchQuery   = inputEvent.target.value;
    const isEmptySearch = searchQuery.trim() === "";

    // get array with matching entries
    const matching_api_refs = filterBySearch(apirefs, searchQuery);

    // show matching results
    renderSearchResults(matching_api_refs);
}

function renderSearchResults(productsToRender)
{
    // remove any existing results
    results.innerHTML = "";

    // loop through every apiref that matched our query
    for(const apiref of productsToRender){
        // clone our apiref template;
        const clone = template.content.cloneNode(true);

        // fill-out the cloned template with the apiref details
        clone.querySelector(".APIref-funcname").innerText = apiref.module + "." + apiref.funcname;
        clone.querySelector(".APIref-syntax").innerText = apiref.syntax;
        clone.querySelector(".APIref-description").innerText = apiref.description;
        clone.querySelector(".APIref-examples").innerText = apiref.examples;
        //clone.querySelector(".link").setAttribute("href", apiref.url);

        // add our clone to the results
        results.appendChild(clone);
    }
}
