//
//  TicTacToe.swift
//  TicTacToe-Base
//
//  Created by Liam Pierce on 1/8/18.
//  Copyright © 2018 Virtual Earth. All rights reserved.
//

import Foundation

//
//  TicTacToe.swift
//  TicTacToe
//
//  Created by Liam Pierce on 1/8/18.
//  Copyright © 2018 Virtual Earth. All rights reserved.
//

import Foundation

// |(1,1)|(2,1)|(3,1)|
// |(1,2)|(2,2)|(3,2)|

//Player 1 : -1
//Player 2 :  1
//Empty    :  0



extension Sequence where Iterator.Element == Int{
    func kindaHomo(_ withZeros:Int=3,_ toKind:Int?=nil)->Int?{
        let ofkind = self.filter{$0 != 0};
        
        if ofkind.count == 0{ return nil; }
        
        let type = ofkind.first(where: {_ in return true})!
        
        if self.underestimatedCount - ofkind.count > withZeros{
            return nil;
        }
        
        for item in self{
            if toKind != nil{
                if item != toKind!{
                    return nil;
                }
            }else{
                if item != type{
                    return nil;
                }
            }
        }
        
        return self.underestimatedCount - ofkind.count;
    }
    
    func homo()->Bool{
        return kindaHomo(0) != nil;
    }
}

extension Array where Element == Int{
    subscript(index: Int...) -> ArraySlice<Int> {
        get {
            var newArray = ArraySlice<Int>();
            for i in index{
                newArray.append(self[i])
            }
            return newArray;
        }
    }
}

enum TicTacGameMode{
    case NORMAL, EXPERT, ONLINE
}

struct TicTacToeBoard : CustomStringConvertible{
    var gameMode : TicTacGameMode = .NORMAL;
    var board = [Int](repeating:0,count:9);
    
    var attachments = [Int:TicTacAI]();
    var routines = [Int:()->Void]()
    
    mutating func attachAI(_ ai:TicTacAI,toPlayer:Int){
        attachments[toPlayer] = ai;
    }
    
    mutating func attachRoutine(_ run: @escaping ()->Void,toPlayer:Int){
        routines[toPlayer] = run;
    }
    
    func convert(_ x:Int,_ y:Int)->Int{
        return 3 * (y - 1) + x - 1;
    }
    
    mutating func play(_ index:Int){
        /*
        let getTurnStart = getTurn();
 */
        board[index] = getTurn();
        /*
        let getTurnAfter = getTurn();
        if (getTurnAfter == getTurnStart){
            print("placement error?");
            
        }
 */
        if let ai = attachments[getTurn()], !(self.hasWinner() != nil || self.hasDraw()){
            print("RECALLING");
            play(ai.getPlay(forBoard:self));
        }
        
        if let routine = routines[getTurn()]{
            routine();
        }
    }
    
    mutating func play(_ x:Int,_ y:Int)->Bool{
        guard board[convert(x,y)] == 0 else{
            return false;
        }
        
        var drop = convert(x,y);
        if gameMode == .EXPERT{
            if (!self.hasDraw()){
                while true{
                    drop = Int(arc4random_uniform(10)) < 3 ? drop : Int(arc4random_uniform(9))
                    if board[drop] == 0{
                        break;
                    }
                }
            }
            
        }
        
        play(drop);
        return true;
    }
    
    func cachePlay(_ index: Int)->TicTacToeBoard{
        var newBoard = self;
        newBoard.play(index);
        return newBoard;
    }
    
    func getTurn()->Int{
        return board.reduce(0,+) == 0 ? -1 : 1
    }
    
    func winningChunk()->[ArraySlice<Int>]{
        return [board[0...2],board[3...5],board[6...8],board[0,3,6],board[1,4,7],board[2,5,8],board[0,4,8],board[2,4,6]]
    }
    
    func chunkIndicies()->[[Int]]{
        return [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
    }
    
    func hasWinner()->Int?{
        for item in winningChunk(){ if item.homo(){ return item.first! } }
        return nil;
    }
    
    func hasDraw()->Bool{
        return board.filter{$0 == 0}.count == 0
    }
    
    func getWinningChunk()->[Int]?{
        for (index,item) in winningChunk().enumerated(){ if item.homo(){ return chunkIndicies()[index] } }
        return nil;
    }
    
    mutating func reset(){
        board = [Int](repeating:0,count:9);
        if attachments[-1] != nil{
            play(attachments[-1]!.getPlay(forBoard:self));
        }
    }
    
    var description: String{
        return board.reduce("",{"\($0)|\($1)"});
    }
}

class TicTacAI{
    
    static var cache = [String:Int?]();
    static var generatingCache = false;
    
    var board:TicTacToeBoard;
    var player = -1;
    
    init(forBoard board:TicTacToeBoard,withPlayer player:Int){
        self.board = board;
        self.player = player;
        if (TicTacAI.cache.count == 0){
            TicTacAI.generatingCache = true;
            TicTacAI.superpolate(fromBoard: board,forPlayer:player);
        }
    }
    
    
    func losingChunks(forBoard polatable:TicTacToeBoard,player:Int)->Int{
        return polatable.winningChunk().reduce(0,{ return $0 + ($1.kindaHomo(1,player) != nil ? 1 : 0) });
    }
    
    static func superpolate(fromBoard polatable:TicTacToeBoard,forPlayer player:Int)->(index:Int,score:Int){
        
        if let winner = polatable.hasWinner(){
            if winner == player{
                return (0,1000);
            }else{
                return (0,-1000);
            }
        }
        if polatable.hasDraw(){
            return (0,0);
        }
        
        var grades = [(index:Int,score:Int)]();
        for (index,item) in polatable.board.enumerated().filter({$1 == 0}){
            let modifiedBoard = polatable.cachePlay(index);
            grades.append((index,superpolate(fromBoard: modifiedBoard,forPlayer:player).score));
        }
        
        if (polatable.getTurn() == player){
            //MAXIMIZE
            let final = grades.max(by: { a,b in return a.score < b.score })!;
            cache[polatable.description] = final.index
            return (final.index,final.score)
        }else{
            //MINIMIZE
            let final = grades.min(by: { a,b in return a.score < b.score })!;
            cache[polatable.description] = final.index
            return (final.index,final.score)
        }
    }
    
    func getPlay(forBoard polatable:TicTacToeBoard)->Int{
        return (TicTacAI.cache[polatable.description] ?? 0)!;
    }
}

