import React from 'react';
import PiLoginButton from './components/PiLoginButton';
import PiPaymentButton from './components/PiPaymentButton';

function App() {
  return (
    <div className="App">
      <h1>Welcome to PiMetaConnect</h1>
      <PiLoginButton />
      <PiPaymentButton />
    </div>
  );
}

export default App;

// Ensure the following component files are linted and valid
// components/PiLoginButton.js
// components/PiPaymentButton.js
