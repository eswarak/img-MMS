let net;

function toggleImage(id,primary,secondary) {
	console.log('Toggling image ...');
    src=document.getElementById(id).src;
    if (src.match(primary)) {
      document.getElementById(id).src=secondary;
    } else {
      document.getElementById(id).src=primary;
    }
    console.log('Analyzing new image ...');
    app();
}

async function app() {
  console.log('Loading mobilenet ...');

  // Load the model.
  net = await mobilenet.load();
  console.log('Successfully loaded model');

  // Make a prediction through the model on our image.
  const imgEl = document.getElementById('img');
  const result = await net.classify(imgEl);
  console.log(result);
}

app();