const counter = document.getElementById("counter");
async function updateCounter() {
    let response = await fetch(
        "https://t5shendiegekxn4lpxvnjade6i0whllr.lambda-url.us-east-1.on.aws/"
    );
    let data = await response.json();
    counter.innerHTML = ` ${data} people have visited this page`;
}
await updateCounter();