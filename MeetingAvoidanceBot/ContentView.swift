//
//  ContentView.swift
//  MeetingAvoidanceBot
//
//  Created by Malte Schöppe on 31.12.24.
//

import SwiftUI

struct ContentView: View {
    @State private var chatMessages: [ChatMessage] = []
    @State private var currentQuestion: String?
    @State private var showingOptions = false
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(chatMessages) { message in
                    ChatBubble(message: message)
                }
            }
            
            if currentQuestion == nil && chatMessages.isEmpty {
                Button(NSLocalizedString("start_button", comment: "")) {
                    startFlowchart()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            if showingOptions {
                HStack {
                    Button(NSLocalizedString("yes", comment: "")) {
                        respondToQuestion(with: "Yes")
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button(NSLocalizedString("no", comment: "")) {
                        respondToQuestion(with: "No")
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            
            if !chatMessages.isEmpty {
                            Button(NSLocalizedString("restart", comment: "")) {
                                restartConversation()
                            }
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
        }
    }
    
    func restartConversation() {
            chatMessages.removeAll()
            currentQuestion = nil
            showingOptions = false
        }
    
    func startFlowchart() {
        askNextQuestion("decision_question")
    }
    
    func respondToQuestion(with answer: String) {
        chatMessages.append(ChatMessage(content: NSLocalizedString(answer.lowercased(), comment: ""), isUser: true))
        showingOptions = false
        
        switch currentQuestion {
        case "decision_question":
            if answer == "Yes" {
                askNextQuestion("async_decision")
            } else {
                askNextQuestion("new_info")
            }
        case "async_decision":
            if answer == "Yes" {
                provideConclusion("use_async_tools")
            } else {
                askNextQuestion("complex_decision")
            }
        case "complex_decision":
            if answer == "Yes" {
                provideConclusion("schedule_meeting")
            } else {
                provideConclusion("use_chat_call")
            }
        case "new_info":
            if answer == "Yes" {
                askNextQuestion("share_async")
            } else {
                askNextQuestion("recurring_checkin")
            }
        case "share_async":
            if answer == "Yes" {
                provideConclusion("use_async_tools")
            } else {
                provideConclusion("schedule_meeting")
            }
        case "recurring_checkin":
            if answer == "Yes" {
                askNextQuestion("providing_value")
            } else {
                provideConclusion("no_meeting")
            }
        case "providing_value":
            if answer == "Yes" {
                provideConclusion("continue_meeting")
            } else {
                provideConclusion("cancel_meeting")
            }
        default:
            break
        }
    }
    
    func askNextQuestion(_ questionKey: String) {
        let question = NSLocalizedString(questionKey, comment: "")
        chatMessages.append(ChatMessage(content: question, isUser: false))
        currentQuestion = questionKey
        showingOptions = true
    }
    
    func provideConclusion(_ conclusionKey: String) {
        let conclusion = NSLocalizedString(conclusionKey, comment: "")
        chatMessages.append(ChatMessage(content: conclusion, isUser: false))
        currentQuestion = nil
        showingOptions = false
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            Text(message.content)
                .padding()
                .background(message.isUser ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            if !message.isUser { Spacer() }
        }.padding(.horizontal)
    }
}
