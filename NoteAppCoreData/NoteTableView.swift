import UIKit
import CoreData

var noteList = [Note]()

var context: NSManagedObjectContext!


class NoteTableView: UITableViewController {
	var firstLoad = true
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func createDefaultNote() {
              let defaultNoteText = "позаниматься спортом 15 минут"
              let newNote = Note(context: context)
              newNote.title = "Ваша первая заметка"
              newNote.desc = defaultNoteText
              
              do {
                  try context.save()
                  noteList.append(newNote)
              } catch {
                  print("Failed to save new note: \(error)")
              }
          }

    
	
	func nonDeletedNotes() -> [Note] {
		var noDeleteNoteList = [Note]()
        
		for note in noteList {
			if(note.deletedDate == nil) {
				noDeleteNoteList.append(note)
			}
		}
		return noDeleteNoteList
	}
	
    override func viewDidLoad() {
        if firstLoad {
            firstLoad = false
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<Note>(entityName: "Note")
            do {
                noteList = try context.fetch(request)
                if noteList.isEmpty {
                    createDefaultNote()
                }
            } catch {
                print("Fetch Failed")
            }
        }
    }
    
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let noteCell = tableView.dequeueReusableCell(withIdentifier: "noteCellID", for: indexPath) as! NoteCell
		
		let thisNote: Note!
		thisNote = nonDeletedNotes()[indexPath.row]
		
		noteCell.titleLabel.text = thisNote.title
		noteCell.descLabel.text = thisNote.desc
		
		return noteCell
	}
	
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return nonDeletedNotes().count
	}
	
	override func viewDidAppear(_ animated: Bool)
	{
		tableView.reloadData()
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		self.performSegue(withIdentifier: "editNote", sender: self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if(segue.identifier == "editNote")
		{
			let indexPath = tableView.indexPathForSelectedRow!
			
			let noteDetail = segue.destination as? NoteDetailVC
			
			let selectedNote : Note!
			selectedNote = nonDeletedNotes()[indexPath.row]
			noteDetail!.selectedNote = selectedNote
			
			tableView.deselectRow(at: indexPath, animated: true)
		}
	}
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            context.delete(noteList[indexPath.row])
            
            do {
                try context.save()
            } catch let error as NSError {
                print("Could not save. Error: \(error), \(error.userInfo)")
            }
            noteList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .top)
        }
            
    }
}
	
