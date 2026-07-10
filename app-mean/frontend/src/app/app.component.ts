import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';

interface Tarea {
  _id: string;
  titulo: string;
  completada: boolean;
}

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent implements OnInit {
  private readonly apiUrl = '/api/tareas';

  tareas: Tarea[] = [];
  nuevoTitulo = '';

  constructor(private http: HttpClient) {}

  ngOnInit(): void {
    this.cargarTareas();
  }

  cargarTareas(): void {
    this.http.get<Tarea[]>(this.apiUrl).subscribe((tareas) => (this.tareas = tareas));
  }

  crearTarea(): void {
    const titulo = this.nuevoTitulo.trim();
    if (!titulo) return;
    this.http.post<Tarea>(this.apiUrl, { titulo }).subscribe((tarea) => {
      this.tareas.push(tarea);
      this.nuevoTitulo = '';
    });
  }

  toggleCompletada(tarea: Tarea): void {
    const completada = !tarea.completada;
    this.http
      .put<Tarea>(`${this.apiUrl}/${tarea._id}`, { titulo: tarea.titulo, completada })
      .subscribe((actualizada) => (tarea.completada = actualizada.completada));
  }

  borrarTarea(tarea: Tarea): void {
    this.http.delete(`${this.apiUrl}/${tarea._id}`).subscribe(() => {
      this.tareas = this.tareas.filter((t) => t._id !== tarea._id);
    });
  }
}
