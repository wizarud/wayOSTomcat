/**
 * @class limz_CommandDelete
 * Command to remove a figure with CommandStack support.
 * 
 * @extends draw2d.command.Command
 */
limz_CommandDelete = draw2d.command.Command.extend({

    NAME: "limz_CommandDelete",

    /**
     * @constructor
     * Create a delete command for the given figure.
     * 
     * @param {draw2d.Figure} figure
     */
    init: function( figure)
    {
       this._super(draw2d.Configuration.i18n.command.deleteShape);
       
       this.parent   = figure.getParent();
       this.figure   = figure;
       this.canvas   = figure.getCanvas();
       this.connections = null;
       this.removedParentEntry = null; // can be null if the figure didn't have any parent shape assigned
       this.indexOfChild = -1;
    },


    /**
     * @method
     * Returns [true] if the command can be execute and the execution of the
     * command modifies the model. e.g.: a CommandMove with [startX,startX] == [endX,endY] should
     * return false. The execution of this Command doesn't modify the model.
     *
     * @return {Boolean} return try if the command modify the model or make any relevant changes
     **/
    canExecute: function()
    {
        // we can only delete the figure if its part of the canvas.
        return this.figure.getCanvas()!==null;
    },

    /**
     * @method
     * Execute the command the first time
     * 
     **/
    execute: function()
    {
       this.redo();
    },
    
    /**
     * @method
     * Undo the command
     *
     **/
    undo: function()
    {
        if(this.parent!==null){
            this.parent.add(this.removedParentEntry.figure, this.removedParentEntry.locator, this.indexOfChild);
            this.canvas.setCurrentSelection(this.parent);
        }
        else{
            this.canvas.add(this.figure);
            this.canvas.setCurrentSelection(this.figure);
        }
        
        if(this.figure instanceof draw2d.Connection){
           this.figure.reconnect();
           this.figure.getSource().getParent().isQuestion = this.isQuestion;
        }
         
        for (var i = 0; i < this.connections.getSize(); ++i){
           this.canvas.add(this.connections.get(i));
           this.connections.get(i).reconnect();
        }

    },

    /**
     * @method
     * 
     * Redo the command after the user has undo this command
     *
     **/
    redo: function()
    {
       this.canvas.setCurrentSelection(null);
        
       // Collect all connections that are bounded to the figure to delete. This connections
       // must be deleted too.
       //
       if (this.connections===null)
       {
          if (this.figure instanceof draw2d.shape.node.Node) {
              this.connections = this.figure.getConnections();
          }
          else{
              this.connections = new draw2d.util.ArrayList();
          }
       }
       
       // remove all connections
       //
       var connection;
       for (var i = 0; i < this.connections.getSize(); ++i) {
    	   connection = this.connections.get(i);
           this.canvas.remove(connection);
    	   
           if (connection.getSource().getConnections().getSize()==0) {
        	   connection.getSource().getParent().isQuestion = undefined;
        	   connection.getSource().getParent().hooksLabel.attr({ bgColor: "#4286F4" });                
           }
       }

       // remove this figure from the parent 
       //
       if (this.parent!==null) {
           // determine the index of the child before remove
          this.indexOfChild = this.parent.getChildren().indexOf(this.figure);
          this.removedParentEntry= this.parent.remove(this.figure);
       }
       // or from the canvas
       else {
           this.canvas.remove(this.figure);
       }

       if (this.figure instanceof draw2d.Connection) {
            this.isQuestion = this.figure.getSource().getParent().isQuestion;
            if (this.figure.getSource().getConnections().getSize()==0) {
                this.figure.getSource().getParent().isQuestion = undefined;
                this.figure.getSource().getParent().hooksLabel.attr({ bgColor: "#4286F4" });                
            }
        }

    }
});