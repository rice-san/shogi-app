//
//  GameScene.swift
//  Shogi
//
//  Created by Rodie Martha on 3/24/18.
//  Copyright © 2018 Royston Martha. All rights reserved.
//

import SpriteKit
import GameplayKit

// All board indexes (tuples) are of the ordered pair (column, row) or (x, y) and these orignate with 1,1 as the upper right corner

func rowToNumericalIndex(row: Character) -> Int  {
	switch row {
	case "a":
		return 1
	case "b":
		return 2
	case "c":
		return 3
	case "d":
		return 4
	case "e":
		return 5
	case "f":
		return 6
	case "g":
		return 7
	case "h":
		return 8
	case "i":
		return 9
	default:
		return 1
	}
}

func numericalIndexToRow(index: Int) -> Character  {
	switch index {
	case 1:
		return "a"
	case 2:
		return "b"
	case 3:
		return "c"
	case 4:
		return "d"
	case 5:
		return "e"
	case 6:
		return "f"
	case 7:
		return "g"
	case 8:
		return "h"
	case 9:
		return "i"
	default:
		return "a"
	}
}

// A type to represent indivual tiles on the game board
class BoardTile : SKSpriteNode {
	var currentPiece: GamePiece?
	func toNumericRepresentation() -> (Int, Int) {
		if let tileIndex = self.name {
			if self.name!.count != 2 {
				print("Error: Invalid name")
				return (-1,-1) // The code is broken so return an invalid tile
			} else {
				let column = Int("\(tileIndex.first!)")!
				let row = rowToNumericalIndex(row: tileIndex.last!)
				return (column, row)
			}
		}
		return (-1, -1) // It should never get here
	}
}

// A type to represent the game board as a whole
class BoardScene: SKScene {
	var gameStarted = false
	
	var heldPiece: GamePiece?
	var currentTile: BoardTile?
	var prevColor = UIColor.black
	var lastPosition = (0,0)
	
	var tiles = Array<Array<BoardTile?>>(repeating: Array<BoardTile?>(repeating: nil, count: 9), count: 9)
	
	// Function to convert tile names to tile indexes in the tiles array
	func getTile(withIndex: String) -> BoardTile? {
		if withIndex.count != 2 {
			return nil
		}
		let column = Int("\(withIndex.first!)")!
		let row = rowToNumericalIndex(row: withIndex.last!)
		return tiles[column][row]
	}
	
	
    override func didMove(to view: SKView) {
		// Identify all tiles and populate tile table
		
    }
	
	override func sceneDidLoad() {
		for row in 0...8 {
			for column in 0...8 {
				print("\(column+1)\(numericalIndexToRow(index: row+1))")
				let tile = self.childNode(withName: "//\(column+1)\(numericalIndexToRow(index: row+1))") as! BoardTile
				self.tiles[column][row] = tile
				print(self.tiles[column][row]!.name!)
			}
		}
		// Temporary thing-a-maboby for testing
		let aPiece = self.childNode(withName: "//king") as! GamePiece
		aPiece.pieceType = .king
		aPiece.placePiece(atLocation: "1a", onBoard: self)
		
		let bPiece = self.childNode(withName: "//gold") as! GamePiece
		bPiece.pieceType = .gold
		bPiece.placePiece(atLocation: "2b", onBoard: self)
	}
    
    
    func touchDown(atPoint pos : CGPoint) {
		
    }
    
    func touchMoved(toPoint pos : CGPoint) {
		
    }
    
    func touchUp(atPoint pos : CGPoint) {
		
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if self.currentTile != nil {
			self.currentTile!.color = self.prevColor
			self.currentTile = nil
		}
		let touch = touches.first!
		let positionInScene = touch.location(in: self)
		let touchedNode = self.atPoint(positionInScene)
		
		
		
		if let name = touchedNode.name
		{
			print("Touched \(name)")
			if let node = touchedNode as? BoardTile {
				// Touched piece indirectly (or just tile)
				print("Got a board tile")
				self.currentTile = node
				self.prevColor = node.color
				node.color = UIColor.darkGray
				if node.currentPiece != nil {
					self.lastPosition = node.toNumericRepresentation()
					self.heldPiece = node.currentPiece
					node.currentPiece = nil
					heldPiece?.parentTile = nil
				}
			}else if let node = touchedNode as? GamePiece {
				// Touched piece directly
				print("Got a piece")
				if let tile = node.parentTile {
					print("Has a parentTile")
					self.lastPosition = tile.toNumericRepresentation()
					self.currentTile = tile
					self.prevColor = tile.color
					tile.color = UIColor.darkGray
					self.heldPiece = node
					tile.currentPiece = nil
					heldPiece!.parentTile = nil
					node.parentTile = nil
				}
			}
		}
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		let touch = touches.first!
		let positionInScene = touch.location(in: self)
		if self.heldPiece != nil {
			heldPiece?.position = positionInScene
		}
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if self.currentTile != nil {
			self.currentTile!.color = self.prevColor
			self.currentTile = nil
		}
		if self.heldPiece != nil {
			let nodes = self.nodes(at: self.heldPiece!.position)
			for node in nodes {
				if let boardPos = node as? BoardTile {
					self.heldPiece?.placePiece(atLocation: boardPos.name!)
					self.heldPiece = nil
				}
			}
		}
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
