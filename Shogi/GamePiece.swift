//
//  GamePiece.swift
//  Shogi
//
//  Created by Rodie Martha on 6/3/18.
//  Copyright © 2018 Royston Martha. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


class GamePiece: SKSpriteNode {
	enum type {
		case king
		case rook
		case bishop
		case gold
		case silver
		case knight
		case lance
		case pawn
	}
	enum color {
		case black
		case white
	}
	enum orientation {
		case forward
		case backward
	}
	var pieceType: type = .king
	var pieceColor: color = .black
	var pieceOrientation: orientation = .forward
	var promoted = false
	weak var parentTile: BoardTile?
	weak var board: BoardScene?
	func getLocationAsNumber() -> (Int, Int)? {
		return parentTile?.toNumericRepresentation()
	}
	// Simplify common operation
	private func getMovement(new: (Int, Int), old: (Int, Int)) -> (Int, Int) {
		return (new.0 - old.0, new.1 - old.1)
	}
	// This is used by multiple pieces (when promoted)
	private func isValidKingMove(newLocation: (Int, Int), oldLocation: (Int, Int)) -> Bool {
		if abs(newLocation.0 - oldLocation.0) <= 1 && abs(newLocation.1 - oldLocation.1) <= 1 {
			print("Move is valid")
			return true
		}
		return false
	}
	// This is used by many promoted pieces as well.
	private func isValidGoldMove(newLocation: (Int, Int), oldLocation: (Int, Int)) -> Bool {
		let movement = getMovement(new: newLocation, old: oldLocation)
		if self.pieceOrientation == .forward {
			switch(movement) {
			case (0,1), (+1,-1), (0,-1), (-1,-1), (1, 0), (-1,0):
				return true
			default:
				return false
			}
		}else{
			switch(movement) {
			case (0,-1), (1,0), (-1,0), (1,1), (0,1), (-1,1):
				return true
			default:
				return false
			}
		}
	}
	func isValidMove(newLocation: (Int, Int), oldLocation: (Int, Int)) -> Bool?{
		if let thisBoard = board {
			/*
			if thisBoard.gameStarted != true {
				return true // If the game hasn't started then all moves are valid.
			}
			*/
		}
		if newLocation.0 > 9 || newLocation.0 < 1 || newLocation.1 > 9 || newLocation.1 < 1 {
			return false
		}
		print(oldLocation)
		print(newLocation)
		print("Motion is equal to \(getMovement(new: newLocation, old: oldLocation))")
		if newLocation == oldLocation {
			// It's the same as before which 'technically' is not legal. Hence we'll return nothing to distinguish between a legal move, a non-legal move, and a non-move
			return nil
		}
		switch(self.pieceType) {
		// TODO: make sure to check that pieces aren't being jumped
		case .king:
			// Check that it only moved one piece away
			return isValidKingMove(newLocation: newLocation, oldLocation: oldLocation)
		case .rook:
			// Check that it only moved exclusively in the x or y direction
			if abs(newLocation.0 - oldLocation.0) > 0 && abs(newLocation.1 - oldLocation.1) == 0 || abs(newLocation.0 - oldLocation.0) == 0 && abs(newLocation.1 - oldLocation.1) > 0 {
				return true
			}
			if self.promoted {
				return isValidKingMove(newLocation: newLocation, oldLocation: oldLocation)
			}
		case .bishop:
			// Check that it moved in a perfect diagonal
			if abs(newLocation.0 - oldLocation.0) == abs(newLocation.1 - oldLocation.1) {
				return true
			}
			if self.promoted {
				return isValidKingMove(newLocation: newLocation, oldLocation: oldLocation)
			}
		// Everything after this is the hard pieces. Gah.
		case .gold:
			// Check that it moved according to its direction
			return self.isValidGoldMove(newLocation: newLocation, oldLocation: oldLocation)
		case .silver:
			if self.promoted {
				// Promoted Silver moves like gold
				return self.isValidGoldMove(newLocation: newLocation, oldLocation: oldLocation)
			}
			let motion = getMovement(new: newLocation, old: oldLocation)
			if self.pieceOrientation == .forward {
				switch(motion) {
				case (0,-1), (1,1), (-1,1), (-1,-1), (1,-1):
					return true
				default:
					return false
				}
			}else{
				switch(motion) {
				case (0,1), (1,1), (-1,1), (-1,-1), (1,-1):
					return true
				default:
					return false
				}
			}
		case .knight:
			if self.promoted {
				// Promoted Knight moves like gold
				return self.isValidGoldMove(newLocation: newLocation, oldLocation: oldLocation)
			}
			let motion = getMovement(new: newLocation, old: oldLocation)
			if self.pieceOrientation == .forward {
				if motion == (1, -2) || motion == (-1, -2) {
					return true
				}
			}else{
				if motion == (1, 2) || motion == (-1, 2) {
					return true
				}
			}
		case .lance:
			if self.promoted {
				// Promoted Lance moves like gold
				return self.isValidGoldMove(newLocation: newLocation, oldLocation: oldLocation)
			}
			let motion = getMovement(new: newLocation, old: oldLocation)
			if self.pieceOrientation == .forward {
				if motion.0 == 0 && motion.1 < 0 {
					return true
				}
			}else{
				if motion.0 == 0 && motion.1 > 0 {
					return true
				}
			}
		case .pawn:
			if self.promoted {
				// Promoted Pawn moves like gold
				return self.isValidGoldMove(newLocation: newLocation, oldLocation: oldLocation)
			}
			let motion = getMovement(new: newLocation, old: oldLocation)
			if self.pieceOrientation == .forward {
				if motion == (0,-1) {
					return true
				}
			}else{
				if motion == (0,1) {
					return true
				}
			}
		}
		return false
	}
	func placePiece(atLocation: String, onBoard: BoardScene? = nil) {
		if let aBoard = onBoard {
			self.board = aBoard
		}
		if atLocation.count != 2 {
			print("Error: Invalid location passed")
		}
		
		let column = Int("\(atLocation.first!)")!
		let row = rowToNumericalIndex(row: atLocation.last!)
		
		print("Move is valid? \(isValidMove(newLocation: (column, row), oldLocation: self.board!.lastPosition) ?? false)")
		
		self.board!.tiles[column-1][row-1]!.currentPiece = self
		self.parentTile = self.board!.tiles[column-1][row-1]
		
		self.position = self.board!.tiles[column-1][row-1]!.position
	}
}
