/*
 *  Notes - panel plugin for Xfce Desktop Environment
 *  Copyright (c) 2009  Mike Massonnet <mmassonnet@xfce.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Library General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 */

using Gtk;
using Pango;

namespace Xnp {

	public class Note : Gtk.Bin {

		public new string name { get; set; }
		private uint save_timeout;
		public Gtk.ScrolledWindow scrolled_window;
		public Xnp.HypertextView text_view;

		public signal void save_data ();

		public Note (string name) {
			this.name = name;

			this.scrolled_window = new Gtk.ScrolledWindow (null, null);
			this.scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);

			this.text_view = new Xnp.HypertextView ();
			this.text_view.wrap_mode = Gtk.WrapMode.WORD;
			this.text_view.left_margin = 2;
			this.text_view.right_margin = 2;
			this.text_view.pixels_above_lines = 1;
			this.text_view.pixels_below_lines = 1;

			this.scrolled_window.add (this.text_view);
			this.scrolled_window.show_all ();
			add (this.scrolled_window);

			var buffer = this.text_view.get_buffer ();
			buffer.changed += buffer_changed_cb;
		}

		~Note () {
			if (this.save_timeout != 0)
				Source.remove (this.save_timeout);
		}

		public override void size_request (ref Gtk.Requisition requisition) {
			Gtk.Requisition child_requisition;
			if (this.child != null && (bool)(this.child.get_flags () & Gtk.WidgetFlags.VISIBLE)) {
				this.child.size_request (out child_requisition);
				requisition = child_requisition;
			}
			else {
				requisition.width = 0;
				requisition.height = 0;
			}
		}

		public override void size_allocate (Gdk.Rectangle allocation) {
			this.allocation = (Gtk.Allocation)allocation;
			if (this.child != null && (bool)(this.child.get_flags () & Gtk.WidgetFlags.VISIBLE)) {
				this.child.size_allocate (allocation);
			}
		}

		/*
		 * Signal callbacks
		 */

		/**
		 * buffer_changed_cb:
		 *
		 * Reset the save_timeout as long as the buffer is under constant
		 * changes and send the save-data signal.
		 */
		private void buffer_changed_cb () {
			if (this.save_timeout > 0) {
				Source.remove (this.save_timeout);
			}
			this.save_timeout = Timeout.add_seconds (60, () => {
				save_data ();
				this.save_timeout = 0;
				return false;
			});
		}

	}

}

/*public class GtkSample : Window {

	public GtkSample () {
		this.title = "Sample Window";
		this.destroy += Gtk.main_quit;
		set_default_size (300, 300);
		var note = new Xnp.Note ("my-note");
		add (note);
	}

	static int main (string[] args) {
		Gtk.init (ref args);
		var sample = new GtkSample ();
		sample.show_all ();
		Gtk.main ();
		return 0;
	}

}*/

