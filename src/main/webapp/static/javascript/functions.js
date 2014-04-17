function initListeners() {
    var parentDomain = getParentDomainFromQuery();
    var parentLocation = parentDomain == null ? getLocalUrl() : parentDomain;

    $(window).load(function() {
        window.parent.postMessage('{"event": "loaded"}', parentLocation);
    });

    $(window).scroll(function() {
        window.parent.postMessage('{"event": "scrolled", "scrollTop": ' + $(window).scrollTop() + ', "scrollLeft": ' + $(window).scrollLeft() +'}', parentLocation);
    });

    window.addEventListener('message', function (event) {
        try {
            var eventObject = JSON.parse(event.data);
            if (eventObject.event == 'scroll') {
                window.scrollTo(eventObject.scrollLeft, eventObject.scrollTop);
            }
        } catch (exception) {
            // the message was not a valid JSON string
        }
    });
}

function initImages(postHTMLToParent) {
    var localUrl = getLocalUrl();
    var parentDomain = getParentDomainFromQuery();
    var parentLocation = parentDomain == null ? localUrl : parentDomain;

    $(window).ready(function() {
        var imageTags = $('img');
        for (var i = 0, imageTagsLength = imageTags.length; i < imageTagsLength; ++i) {
            var imageTag = $(imageTags[i]);
            var fileref = imageTag.attr('src');
            if (fileref.substr(0,6) === 'images') {
                var imageUrl = localUrl + '/pressgang-ccms/rest/1/image/get/raw/' + fileref.substr(7, fileref.length - 11);
                imageTag.attr('src', imageUrl);
            }
        }

        if (postHTMLToParent) {
            // post the rendered html back to the parent
            window.parent.postMessage("{\"html\":\"" + $("html").html().replace(/\\/g,"\\\\").replace(/\t/g,"\\t").replace(/\n/g,"\\n").replace(/"/g,"\\\"") + "\",\"href\":\"" + document.location.href + "\"}", parentLocation);
        }
    });
}

function getParentDomainFromQuery() {
    var parentDomainRegex = /parentDomain=(.*?)(&|$)/;
    var matches = parentDomainRegex.exec(window.location.search);
    return matches == null ? null : matches[1];
}

function getLocalUrl() {
    return window.location.protocol + "//" + window.location.hostname + ":" + window.location.port;
}