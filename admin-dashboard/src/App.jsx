import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';

import ProtectedRoute from './components/ProtectedRoute.jsx';
import { AuthProvider } from './context/AuthContext.jsx';
import CommentsPage from './pages/CommentsPage.jsx';
import EventEditPage from './pages/EventEditPage.jsx';
import EventsListPage from './pages/EventsListPage.jsx';
import LoginPage from './pages/LoginPage.jsx';
import StudentsPage from './pages/StudentsPage.jsx';

export default function App() {
  return (
    <AuthProvider>
      {/* Opt in early to the v7 behaviours so the console stays quiet. */}
      <BrowserRouter
        future={{ v7_startTransition: true, v7_relativeSplatPath: true }}
      >
        <Routes>
          <Route path="/login" element={<LoginPage />} />
          <Route element={<ProtectedRoute />}>
            <Route path="/" element={<EventsListPage />} />
            <Route path="/events/new" element={<EventEditPage />} />
            <Route path="/events/:eventId" element={<EventEditPage />} />
            <Route path="/comments" element={<CommentsPage />} />
            <Route path="/students" element={<StudentsPage />} />
          </Route>
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}
