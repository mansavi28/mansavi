

package com.servlet;

import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/home")
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }

        String username = (String) session.getAttribute("username");

        PrintWriter out = response.getWriter();

        out.println("<!DOCTYPE html>");
        out.println("<html><head><title>Student Home</title></head><body>");
        out.println("<h1>Student Home</h1>");
        out.println("<h2>Welcome " + username + "</h2>");
        out.println("</body></html>");
    }
}
