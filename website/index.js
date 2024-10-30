window.addEventListener('DOMContentLoaded', (event) =>{
  getVisitCount();
})

const functionApi = '';

const getVisitCount = () =>{
  let count = 45
  fetch(functionApi).then(response => {
    return response.json()
  }).then(response =>{
    console.log("Called API")
    count = response.count;
    document.getElementById("counter").innerText = count;
  }).catch(function(error){
    console.log(error)
  });
  return count;
}

const counter = document.getElementById("counter");
async function updateCounter() {
    let response = await fetch(
        "https://4ktzqn5mhxebbwrd454qpogcaa0jhbei.lambda-url.us-east-1.on.aws/"
    );
    let data = await response.json();
    counter.innerHTML = `Thsi page has been visited by ${data} people`;
}
updateCounter();