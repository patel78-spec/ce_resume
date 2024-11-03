$(document).ready(function (e) {
    $win = $(window);
    $navbar = $('#header');
    $toggle = $('.toggle-button');
    var width = $navbar.width();
    toggle_onclick($win, $navbar, width);

    // resize event
    $win.resize(function () {
        toggle_onclick($win, $navbar, width);
    });

    $toggle.click(function (e) {
        $navbar.toggleClass("toggle-left");
    })

});

function toggle_onclick($win, $navbar, width) {
    if ($win.width() <= 768) {
        $navbar.css({ left: `-${width}px` });
    } else {
        $navbar.css({ left: '0px' });
    }
}

var typed = new Typed('#typed', {
    strings: [
        'Cloud Engineer',
        'Cloud Practitioner',
        'DevOps Engineer'
    ],
    typeSpeed: 50,
    backSpeed: 50,
    loop: true
});

var typed_2 = new Typed('#typed_2', {
    strings: [
        'Cloud Engineer',
        'Cloud Practitioner',
        'DevOps Engineer'
    ],
    typeSpeed: 50,
    backSpeed: 50,
    loop: true
});

document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();

        document.querySelector(this.getAttribute('href')).scrollIntoView({
            behavior: 'smooth'
        });
    });
});

async function updateCounter() {
    try {
        let response = await fetch(
            "https://3o7xe7dvjrjscd4rt4ltql6k4u0filvf.lambda-url.us-east-1.on.aws/"
        );

        if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
        }

        let counter = document.getElementById('counter-views'); // Corrected typo here
        // let views = document.getElementById('counter-views')
        if (!counter) {
            console.error("Counter element not found in the document.");
            return;
        }

        let data = await response.json();
        console.log(data);

        counter.innerHTML = `Views: ${data}`;

        
    } catch (error) {
        console.error("Failed to update counter:", error);

        let counter = document.getElementById('counter'); // Check counter existence again
        if (counter) {
            counter.innerHTML = "Unable to load visitor count.";
        }
    }
}
updateCounter();
