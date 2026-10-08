module UtilityService
  module South
    class ResponseMapper < UtilityService::ResponseMapper
      def retrieve_books(_response_code, response_body)
        { books: map_books(response_body['Libros']) }
      end

      def retrieve_notes(_response_code, response_body)
        { notes: map_notes(response_body['Notas']) }
      end

      private

      def map_books(books)
        books.map do |book|
          {
            id: book['Id'],
            title: book['Titulo'],
            author: book['Autor'],
            genre: book['Genero'],
            image_url: book['ImagenUrl'],
            publisher: book['Editorial'],
            year: book['Año']
          }
        end
      end

      def map_notes(notes)
        notes.map do |note|
          last_name, first_name = note['NombreCompletoAutor'].split(' ', 2)
          {
            title: note['TituloNota'],
            type: note['ReseniaNota'] ? 'review' : 'critique',
            created_at: note['FechaCreacionNota'],
            content: note['Contenido'],
            user: { email: note['EmailAutor'], first_name: first_name, last_name: last_name },
            book: {
              title: note['TituloLibro'],
              author: note['NombreAutorLibro'],
              genre: note['GeneroLibro']
            }
          }
        end
      end
    end
  end
end
