require 'rails_helper'

describe UtilityService::North::ResponseMapper do
  describe '#retrieve_notes' do
    subject(:mapped_notes) do
      described_class.new.retrieve_notes(response_code, 'notas' => [note])[:notes]
    end

    let(:response_code) { Faker::Number.number(digits: 3) }
    let(:mapped_note) { mapped_notes.first }
    let(:type) { %w[resenia critica opinion].sample }
    let(:book) do
      {
        'id' => Faker::Number.number,
        'titulo' => Faker::Book.title,
        'autor' => Faker::Book.author,
        'genero' => Faker::Book.genre
      }
    end
    let(:note) do
      {
        'id' => Faker::Number.number,
        'titulo' => Faker::Book.title,
        'tipo' => type,
        'contenido' => Faker::Lorem.paragraph,
        'fecha_creacion' => Faker::Time.backward.iso8601,
        'autor' => {
          'datos_de_contacto' => {
            'email' => Faker::Internet.email,
            'telefono' => Faker::PhoneNumber.phone_number
          },
          'datos_personales' => {
            'nro_documento' => Faker::Number.number(digits: 8).to_s,
            'nombre' => Faker::Name.first_name,
            'apellido' => Faker::Name.last_name
          }
        },
        'libro' => book
      }
    end

    it 'maps the note title, creation date and content' do
      expect(mapped_note.slice(:title, :created_at, :content)).to eq(
        title: note['titulo'], created_at: note['fecha_creacion'], content: note['contenido']
      )
    end

    it 'maps the note author as the user' do
      expect(mapped_note[:user]).to eq(
        email: note['autor']['datos_de_contacto']['email'],
        first_name: note['autor']['datos_personales']['nombre'],
        last_name: note['autor']['datos_personales']['apellido']
      )
    end

    it 'maps the note book' do
      expect(mapped_note[:book]).to eq(
        title: book['titulo'], author: book['autor'], genre: book['genero']
      )
    end

    context 'when the note type is resenia' do
      let(:type) { 'resenia' }

      it 'maps the type as review' do
        expect(mapped_note[:type]).to eq('review')
      end
    end

    context 'when the note type is critica' do
      let(:type) { 'critica' }

      it 'maps the type as critique' do
        expect(mapped_note[:type]).to eq('critique')
      end
    end

    context 'when the note type is opinion' do
      let(:type) { 'opinion' }

      it 'maps the type as critique' do
        expect(mapped_note[:type]).to eq('critique')
      end
    end

    context 'when the note comes without book' do
      let(:note) { super().except('libro') }

      it 'maps the book as nil' do
        expect(mapped_note[:book]).to be_nil
      end
    end
  end
end
