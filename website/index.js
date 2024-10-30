const counter = document.getElementById("counter");
async function updateCounter() {
    let response = await fetch(
        "https://4ktzqn5mhxebbwrd454qpogcaa0jhbei.lambda-url.us-east-1.on.aws/"
    );
    let data = await response.json();
    counter.innerHTML = ` ${data} people have visited this page`;
}
updateCounter();