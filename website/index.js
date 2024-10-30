document.addEventListener("DOMContentLoaded", async () => {
    const counter = document.getElementById("counter");

    async function updateCounter() {
        try {
            let response = await fetch(
                "https://t5shendiegekxn4lpxvnjade6i0whllr.lambda-url.us-east-1.on.aws/"
            );

            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }

            let data = await response.json();
            console.log(data);

            counter.innerHTML = `${data.count} people have visited this page`;
        } catch (error) {
            console.error("Failed to update counter:", error);
            counter.innerHTML = "Unable to load visitor count.";
        }
    }

    updateCounter();
});

async function updateCounter() {
    let response = await fetch(
        "https://t5shendiegekxn4lpxvnjade6i0whllr.lambda-url.us-east-1.on.aws/"
    );
    console.log(response)
    console.log('...............................')
    let data = await response.json();
    console.log(data)
    counter.innerHTML = ` ${data} people have visited this page`;
}
