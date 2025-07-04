import { useState } from 'react'
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom'
import './App.css'

function App() {
  const [count, setCount] = useState(0)

  return (
    <Router>
    <div className="min-h-screen bg-gray-100 flex items-center justify-center">
      <div className="max-w-md mx-auto bg-white rounded-xl shadow-md overflow-hidden">
        <div className="p-8">
          <div className="text-center">
            <div className="mb-6">
              <img 
                src="https://cdn.discordapp.com/emojis/1045021806144262244.webp?size=80" 
                alt="Kekstarter Logo" 
                className="mx-auto w-16 h-16 mb-4"
              />
            </div>
            <h1 className="text-3xl font-bold text-gray-900 mb-4">
              my-awesome-demo
            </h1>
            <p className="text-gray-600 mb-6">
              <no value>
            </p>
            <div className="space-y-4">
              <button
                onClick={() => setCount((count) => count + 1)}
                className="w-full px-4 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-600 transition-colors"
              >
                Count is {count}
              </button>
              
              <nav className="flex space-x-4 justify-center">
                <Link to="/" className="text-blue-500 hover:text-blue-700">Home</Link>
                <Link to="/about" className="text-blue-500 hover:text-blue-700">About</Link>
              </nav>
              
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <Routes>
      <Route path="/" element={<div>Home Page</div>} />
      <Route path="/about" element={<div>About Page</div>} />
    </Routes>
    </Router>
  )
}

export default App
