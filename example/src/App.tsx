import React, { useState } from "react";
import { View, Text, Button, Alert, Image, TouchableOpacity, StyleSheet, TextInput } from "react-native";
import { startPayment_ } from 'edge';
import { WebView } from 'react-native-webview';

const OrderCreationScreen = () => {
  const [redirectUrl, setRedirectUrl] = useState<string | null>(null);
  const [returnUrl, setReturnUrl] = useState<string>(""); // State for the input return URL

  const handleTransaction = (status: string, code?: number, message?: string) => {
    if (status === "Transaction successful") {
      Alert.alert("Payment Completed", "Transaction was successful");
    } else {
      Alert.alert("Payment Failed", `Error: ${message || "Unknown error"} (Code: ${code || "N/A"})`);
    }
  };

  const handleTransactionSuccess = (redirectUrl: string) => {
    console.log("Redirect URL inside handleTransactionSuccess is:", redirectUrl); // Log the URL before passing it
    const paymentOptionsData = {
      options: {
        redirectUrl: redirectUrl,
      },
    };

    // Call startPayment_ and pass the handleTransaction callback
    startPayment_(paymentOptionsData, (response: any) => {
      console.log("Payment Response:", response);
      handleTransaction(response.status, response.code, response.message);
    });
  };

  const initializePaymentProcess = () => {
    if (returnUrl.trim() === "") {
      Alert.alert("Error", "Please provide a valid RETURN_URL.");
      return;
    }

    // Proceed with the return URL provided by the user
    handleTransactionSuccess(returnUrl);
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Merchant Dummy App</Text>

      {/* Display the image */}
      <Image
        source={require('./assets/head_phone.jpg')} // Ensure the image is placed inside `assets` folder
        style={styles.image}
      />

      {/* Input field for RETURN_URL */}
      <TextInput
        style={styles.input}
        placeholder="Enter RETURN_URL"
        value={returnUrl}
        onChangeText={setReturnUrl}
      />

      {/* Custom button with TouchableOpacity */}
      <TouchableOpacity style={styles.button} onPress={initializePaymentProcess}>
        <Text style={styles.buttonText}>Proceed To Pay</Text>
      </TouchableOpacity>

      {/* Display WebView when redirectUrl is set */}
      {redirectUrl && <WebView source={{ uri: redirectUrl }} style={styles.webview} />}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20,
  },
  image: {
    width: 200,
    height: 200,
    marginBottom: 30,
    borderRadius: 100, // Make the image circular
  },
  input: {
    width: '100%',
    padding: 15,
    borderWidth: 1,
    borderColor: '#ccc',
    borderRadius: 10,
    marginBottom: 20,
    textAlign: 'center',
  },
  button: {
    backgroundColor: '#4CAF50',
    padding: 15,
    borderRadius: 10,
    marginBottom: 20,
  },
  buttonText: {
    color: 'white',
    fontSize: 18,
    textAlign: 'center',
  },
  webview: {
    marginTop: 20,
    width: '100%',
    height: '60%',
  },
});

export default OrderCreationScreen;
