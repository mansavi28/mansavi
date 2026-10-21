import java.io.*;
import java.net.*;

public class Client {

    public static void main(String[] args) {

        try {
            // Connect to server
            Socket socket = new Socket("localhost", 5000);

            System.out.println("Connected to server.");

            // Receive message from server
            BufferedReader input = new BufferedReader(
                    new InputStreamReader(socket.getInputStream())
            );

            // Send message to server
            PrintWriter output = new PrintWriter(
                    socket.getOutputStream(), true
            );

            // Send message
            output.println("Hello Server");

            // Receive response
            String response = input.readLine();

            System.out.println("Server says: " + response);

            // Close connection
            socket.close();

            System.out.println("Connection closed.");

        } catch (IOException e) {
            System.out.println("Error: " + e.getMessage());
        }
    }
}  
    


        
