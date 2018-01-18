//
//  TicTacToeController.swift
//  TicTacToe
//
//  Created by Liam Pierce on 1/17/18.
//  Copyright © 2018 Virtual Earth. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView{
    func recolor(to newcolor:UIColor){
        self.image = self.image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = newcolor
    }
}

class TicTacToeController : UIViewController, BoardInteractable{
    
    @IBOutlet var userOneIcon: UIImageView!;
    @IBOutlet var userTwoIcon: UIImageView!;
    
    @IBOutlet var userOneText: UILabel!;
    @IBOutlet var userTwoText: UILabel!;
    
    @IBOutlet var difficultyButton: UIButton!;
    
    @IBOutlet var board: BoardDraw!;
    
    var playerTwoActive = false;
    var playerOneActive = false;
    
    var lock = false;
    
    var boardData = TicTacToeBoard();
    var scores = [-1:0,0:0,1:0]
    
    @IBAction func playerTwoTurnOn(sender:UISwitch){
        if playerTwoActive{
            userTwoIcon.image = #imageLiteral(resourceName: "computer");
            boardData.attachAI(AppDelegate.OAI, toPlayer: 1);
            boardData.attachRoutine({ self.redraw() }, toPlayer: 1);
        }else{
            userTwoIcon.image = #imageLiteral(resourceName: "singleplayer")
            boardData.attachments[1] = nil;
            boardData.routines[1] = nil;
        }
        
        playerTwoActive = sender.isOn
    }
    
    @IBAction func playerOneTurnOn(sender:UISwitch){
        if playerOneActive{
            userOneIcon.image = #imageLiteral(resourceName: "computer");
            boardData.attachAI(AppDelegate.XAI, toPlayer: -1);
            boardData.attachRoutine({ self.redraw() }, toPlayer: -1);
        }else{
            userOneIcon.image = #imageLiteral(resourceName: "singleplayer")
            boardData.attachments[-1] = nil;
            boardData.routines[-1] = nil;
        }
        
        playerOneActive = sender.isOn
    }
    
    @IBAction func difficulty(){
        let change = difficultyButton.currentTitle == "Expert" ? "Normal" : "Expert";
        if change == "Normal"{
            boardData.gameMode = .NORMAL;
        }else{
            boardData.gameMode = .EXPERT;
        }
        print("Changing to: \(change)")
        difficultyButton.setTitle(change, for: .normal);
    }
    
    @IBAction func tapSquare(sender: UITapGestureRecognizer){
        if lock{ return; }
        let play = board.getPlacementRect(sender.location(in: board));
        boardData.play(play.0,play.1);
        print("Playing : \(play)");
        redraw();
        handleTurn();
    }
    
    func handleTurn(){
        if (boardData.hasWinner() != nil || boardData.hasDraw()){ return }
        if boardData.getTurn() == -1{
            userOneIcon.recolor(to: .blue)
            userTwoIcon.recolor(to: .black)
        }else{
            userOneIcon.recolor(to: .black)
            userTwoIcon.recolor(to: .blue)
        }
    }
    
    func handleWin(winner:Int){
        lock = true;
        scores[winner]! += 1;
        rescore();
        redraw();
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { timer in
            self.boardData.reset()
            self.redraw();
            self.lock = false;
            timer.invalidate()
        })
    }
    
    func rescore(){
        userOneText.text = "(X)  \(scores[-1]!)";
        userTwoText.text = "\(scores[1]!)  (O)";
    }
    
    func redraw(){
        board.setNeedsDisplay();
    }
    
    override func viewDidLoad(){
        board.link(with: self);
        boardData.attachAI(AppDelegate.OAI, toPlayer: 1);
        boardData.attachRoutine({ self.redraw() }, toPlayer: 1);
        redraw();
    }
    
}
