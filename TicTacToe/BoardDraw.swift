//
//  BoardDraw.swift
//  TicTacToe
//
//  Created by Liam Pierce on 1/17/18.
//  Copyright © 2018 Virtual Earth. All rights reserved.
//

import Foundation
import UIKit

protocol BoardInteractable{
    var boardData: TicTacToeBoard { get };
    
    func handleWin(winner:Int);
}

protocol BoardInteractor{
    var controllerLink : BoardInteractable! { get set }
}

extension BoardInteractor{
    mutating func link(with controller:BoardInteractable){
        self.controllerLink = controller;
    }
}

class BoardDraw: UIView, BoardInteractor{
    var controllerLink: BoardInteractable! = nil;
    
    let lineWidth = 5.0;
    
    var width : Double! = nil;
    var height : Double! = nil;
    
    func getPlacementRect(_ location: CGPoint)->(Int,Int){
        let width = Double(self.bounds.width);
        let height = Double(self.bounds.height);
        
        let x = Double(location.x);
        let y = Double(location.y);
        
        var rect = (1,1);
        
        if x < width / 3 - lineWidth{
            rect.0 = 1;
        }else if x > width / 3 - lineWidth && x < 2 * width / 3 - lineWidth{
            rect.0 = 2;
        }else{
            rect.0 = 3;
        }
        
        if y < height / 3 - lineWidth{
            rect.1 = 1;
        }else if y > height / 3 - lineWidth && y < 2 * height / 3 - lineWidth{
            rect.1 = 2;
        }else{
            rect.1 = 3;
        }
        
        return rect;
    }
    
    func drawBounding(_ x:Double,_ y:Double,_ width:Double,_ height:Double){
        let bound = CGRect(x: x, y: y, width: width, height: height);
        let path = UIBezierPath.init(rect: bound)
        UIColor.white.setFill()
        path.fill();
    }
    
    func drawPlay(_ player:String,_ doHighlight: Bool,_ rect:CGRect){
        
        let textFont = UIFont.boldSystemFont(ofSize: 130);
        let textFontAttributes = [
                                NSAttributedStringKey.font: textFont,
                                NSAttributedStringKey.foregroundColor: doHighlight ? UIColor.blue : UIColor.white,
                                  ]
        
        player.draw(in: rect, withAttributes: textFontAttributes)
    }
    
    func drawPlay(_ play: String, atPlacementRect rect:(Int,Int),highlight:Bool){
        let height = Double(self.bounds.height);
        let width = Double(self.bounds.width);
        
        var charSizeData = ["O":(50.0,50.0),"X":(45.0,45.0)]
        
        drawPlay(play,highlight,CGRect(
            x: width / 6 - charSizeData[play]!.0 + (width / 3 * Double(rect.0 - 1)),
            y: -5 + (height / 3 * Double(rect.1 - 1)),
            width: width / 3, height: height / 3));
    }
    
    override func draw(_ rect: CGRect) {
        let height = Double(self.bounds.height);
        let width = Double(self.bounds.width);
        
        
        UIGraphicsGetCurrentContext()?.clear(self.bounds)
        
        
        drawBounding(width / 3 - lineWidth,0,lineWidth,height);
        drawBounding(2 * width / 3 - lineWidth,0,lineWidth,height);
        drawBounding(0,height / 3 - lineWidth,height,lineWidth);
        drawBounding(0,2 * height / 3 - lineWidth,width,lineWidth);
        
        let winner = controllerLink.boardData.hasWinner();
        
        for (index,block) in controllerLink.boardData.board.enumerated(){
            if block == 0 { continue; }
            
            var player = "O";
            if block == -1{
                player = "X";
            }
            
            drawPlay(player,atPlacementRect:(Int(index % 3) + 1,Int(floor(Double(index) / 3.0) + 1)),highlight:false)
        }
        
        if (winner != nil){
            for index in controllerLink.boardData.getWinningChunk()!{
                drawPlay(winner! == -1 ? "X" : "O",atPlacementRect:(Int(index % 3) + 1,Int(floor(Double(index) / 3.0) + 1)),highlight:true)
            }
            
            controllerLink.handleWin(winner:winner!);
        }
        
        if controllerLink.boardData.hasDraw(){
            controllerLink.handleWin(winner: 0);
        }
    }
    
}
