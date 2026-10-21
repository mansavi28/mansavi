import java.io.*;
import java.net.*;

public class Server {

    public static void main(String[] args) {

        try {
            // Create server on port 5000
            ServerSocket serverSocket = new ServerSocket(5000);

            System.out.println("Server started...");
            System.out.println("Waiting for client...");

            // Wait for client connection
            Socket socket = serverSocket.accept();

            System.out.println("Client connected.");

            // Receive message from client
            BufferedReader input = new BufferedReader(
                    new InputStreamReader(socket.getInputStream())
            );

            // Send message to client
            PrintWriter output = new PrintWriter(
                    socket.getOutputStream(), true
            );

            // Read client's message
            String message = input.readLine();

            System.out.println("Client says: " + message);

            // Send response to client
            output.println("Hello Client");

            // Close connection
            socket.close();
            serverSocket.close();

            System.out.println("Connection closed.");

        } catch (IOException e) {
            System.out.println("Error: " + e.getMessage());
        }
    }
}