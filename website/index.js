document.addEventListener("DOMContentLoaded", async () => {
    const counter = document.getElementById("counter");

    async function updateCounter() {
        try {
            let response = await fetch(
                "https://xk3fq3hbnrbbvue6mfzeozjv5y0sxbrz.lambda-url.us-east-1.on.aws/"
            );

            if (!response.ok) {
                throw new Error(`HTTP error! Status: ${response.status}`);
            }

            let data = await response.json();
            console.log(data);

            counter.innerHTML = `${data} people have visited this page`;
        } catch (error) {
            console.error("Failed to update counter:", error);
            counter.innerHTML = "Unable to load visitor count.";
        }
    }

    updateCounter();
});

