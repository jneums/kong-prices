import { Route, Routes } from 'react-router';
import Token from './pages/Token';
import Home from './pages/Home';

function App() {
  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path={`/tokens/:token`} element={<Token />} />
    </Routes>
  );
}

export default App;
